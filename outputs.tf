// Outputs for Phase 1: Kinesis stream, IoT endpoint, certificate, and thing

output "kinesis_stream_name" {
  description = "Kinesis stream name created for IoT data"
  value       = aws_kinesis_stream.iot_data_stream.name
}

output "kinesis_stream_arn" {
  description = "ARN of the created Kinesis stream"
  value       = aws_kinesis_stream.iot_data_stream.arn
}

output "iot_endpoint_address" {
  description = "AWS IoT Data endpoint address (Data-ATS)"
  value       = data.aws_iot_endpoint.iot.endpoint_address
}

output "iot_thing_name" {
  description = "Name of the created IoT Thing"
  value       = aws_iot_thing.device.name
}

output "iot_certificate_arn" {
  description = "ARN of the created IoT certificate"
  value       = aws_iot_certificate.device_cert.arn
}

output "iot_certificate_id" {
  description = "ID of the created IoT certificate"
  value       = aws_iot_certificate.device_cert.id
}

output "iot_policy_name" {
  description = "Name of the IoT policy created"
  value       = aws_iot_policy.device_policy.name
}

