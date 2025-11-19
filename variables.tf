// Variables for Phase 1 Terraform implementation (base AWS infrastructure)

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile to use; leave empty to use default credentials chain"
  type        = string
  default     = ""
}

variable "project_short" {
  description = "Short project identifier used in resource names"
  type        = string
  default     = "scops"
}

variable "vpc_name" {
  description = "Human-friendly VPC name"
  type        = string
  default     = "scops-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets (one per AZ). These are isolated by default to avoid NAT costs."
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.101.0/24"]
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to bastion; set to your office/home IP (default is 0.0.0.0/0 - change it)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "artifact_bucket_name" {
  description = "S3 bucket name for CI/CD artifacts. Choose a globally unique name. Leave empty to auto-generate."
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default = {
    Project = "smart-cityops"
    Phase   = "phase-1"
  }
}
