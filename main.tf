
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "aws" {
  region = var.aws_region
  # Use the profile if provided; otherwise set to null so the provider
  # falls back to the default credentials chain (env vars, instance role, etc).
  profile = var.aws_profile != "" ? var.aws_profile : null
}

// Basic data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_iot_endpoint" "iot" {
  // returns the account-specific IoT Data endpoint (Data-ATS recommended)
  endpoint_type = "iot:Data-ATS"
}

// Kinesis Stream
resource "aws_kinesis_stream" "iot_data_stream" {
  name             = var.kinesis_stream_name
  shard_count      = var.kinesis_shard_count
  retention_period = var.kinesis_retention_hours

  tags = merge(var.common_tags, {
    Name = var.kinesis_stream_name
  })
}

// IoT Thing + Certificate + Policy
// -----------------------------
resource "aws_iot_thing" "device" {
  name = var.iot_thing_name
  // optional attributes can be added here
}

// Create an X.509 certificate for the device. This resource registers a certificate
// in AWS IoT. The certificate material is returned and may be used out-of-band to
// provision devices. We enable it by default.
resource "aws_iot_certificate" "device_cert" {
  active = true
}

// Attach the certificate as a principal to the IoT Thing
resource "aws_iot_thing_principal_attachment" "attach_cert" {
  # Newer provider versions expect `thing` (not `thing_name`).
  thing     = aws_iot_thing.device.name
  principal = aws_iot_certificate.device_cert.arn
}

// IoT Policy allowing device to connect and publish to the expected topic(s).
resource "aws_iot_policy" "device_policy" {
  name   = var.iot_policy_name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iot:Connect"
      ],
      "Resource": [
        "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:client/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iot:Publish",
        "iot:Subscribe",
        "iot:Receive"
      ],
      "Resource": [
        "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/iot/topic/data",
        "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/iot/topic/data"
      ]
    }
  ]
}
POLICY
}

// Attach the IoT Policy to the certificate so the device can use it
resource "aws_iot_policy_attachment" "attach_policy" {
  # Provider expects `policy` (policy name) and `target` (principal ARN)
  policy = aws_iot_policy.device_policy.name
  target = aws_iot_certificate.device_cert.arn
}

// -----------------------------
// IAM role & policy for IoT Topic Rule -> Kinesis
// IoT needs an IAM role that it can assume in order to write to Kinesis.
// -----------------------------
resource "aws_iam_role" "iot_kinesis_role" {
  name = var.iot_kinesis_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = var.common_tags
}

resource "aws_iam_role_policy" "iot_kinesis_policy" {
  name = "${var.iot_kinesis_role_name}-policy"
  role = aws_iam_role.iot_kinesis_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ],
        Resource = [
          aws_kinesis_stream.iot_data_stream.arn
        ]
      }
    ]
  })
}

// -----------------------------
// IoT Topic Rule: read from MQTT topic and forward to Kinesis
// SQL: SELECT * FROM 'iot/topic/data'
// -----------------------------
resource "aws_iot_topic_rule" "iot_to_kinesis" {
  name        = "iot_to_kinesis_rule"
  description = "Forward IoT device messages on 'iot/topic/data' to Kinesis stream"
  enabled     = true

  # `sql_version` is required in newer provider versions.
  sql_version = "2016-03-23"
  sql         = "SELECT * FROM 'iot/topic/data'"

  // Kinesis action: IoT service will assume the role and write to the stream.
  kinesis {
    role_arn    = aws_iam_role.iot_kinesis_role.arn
    stream_name = aws_kinesis_stream.iot_data_stream.name
    // Use IoT SQL expression for partition key. We escape Terraform interpolation
    // so the IoT service evaluates the expression at runtime.
    partition_key = "$${topic()}"
  }

}

// Tags or additional configuration can be added as needed
