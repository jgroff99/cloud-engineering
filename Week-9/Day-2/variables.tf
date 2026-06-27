variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
  default     = "jordan-tf-lab-2026"
}

variable "project_name" {
  type        = string
  description = "Project name used in resource naming"

  validation {
    condition     = length(var.project_name) <= 20
    error_message = "project_name must be 20 characters or fewer."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "instance_type_map" {
  type        = map(string)
  description = "Instance type per environment"
  default = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }
}

variable "vpc_cidr" {
  type        = string
  description = "Parent CIDR block for VPC subnet calculations"
  default     = "10.0.0.0/16"
}
