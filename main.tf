// Phase 1: Basic AWS networking and minimal IAM roles for Smart CityOps
// - VPC with public & private subnets
// - Internet Gateway + public route table
// - Security Groups (bastion and internal)
// - Minimal IAM roles (EC2 role for SSM, CI role for future CI/CD)
// This configuration prefers low-cost choices (no NAT Gateway) and leaves
// private subnets isolated (no outbound internet) to avoid recurring charges.

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.common_tags, { Name = var.vpc_name })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags                    = merge(var.common_tags, { Name = "${var.vpc_name}-public-${count.index}" })
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(var.common_tags, { Name = "${var.vpc_name}-private-${count.index}" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.common_tags, { Name = "${var.vpc_name}-igw" })
}

data "aws_availability_zones" "available" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
  required_version = ">= 1.1.0"
}



// Internal SG for application resources - allow traffic from within the VPC
resource "aws_security_group" "internal" {
  name   = "${var.vpc_name}-internal-sg"
  vpc_id = aws_vpc.this.id

  description = "Allow internal communication within the VPC"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.vpc_name}-internal-sg" })
}

// -----------------------------
// Minimal IAM Roles for future services
//  - EC2 role with SSM access (for management and future agents)
//  - CI role (CodeBuild) with minimal S3 read/write to store artifacts
// -----------------------------
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project_short}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "ci_role" {
  name = "${var.project_short}-ci-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ci_s3_read_attach" {
  role       = aws_iam_role.ci_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

// Lightweight inline policy for CI to allow uploading artifacts to a specific S3 prefix
resource "aws_iam_policy" "ci_artifact_policy" {
  name        = "${var.project_short}-ci-artifacts"
  description = "Allow CI to put objects into project artifacts prefix (minimal)"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::${var.artifact_bucket_name}",
          "arn:aws:s3:::${var.artifact_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ci_artifacts_attach" {
  name       = "${var.project_short}-ci-artifacts-attach"
  roles      = [aws_iam_role.ci_role.name]
  policy_arn = aws_iam_policy.ci_artifact_policy.arn
}

// Optionally create a small S3 bucket for artifacts (versioning disabled by default)
resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifact_bucket_name

  tags = merge(var.common_tags, { Name = "${var.project_short}-artifacts" })

  lifecycle_rule {
    enabled = true
  }

}

// IoT Thing + Certificate + Policy
// -----------------------------

