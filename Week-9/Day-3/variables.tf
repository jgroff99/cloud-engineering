variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "project" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "Subnet definitions — key becomes the resource identifier and Name tag suffix"
  type = map(object({
    newbits = number
    netnum  = number
    public  = bool
  }))
  default = {
    "public-a"  = { newbits = 8, netnum = 1, public = true }
    "public-b"  = { newbits = 8, netnum = 2, public = true }
    "private-a" = { newbits = 8, netnum = 11, public = false }
    "private-b" = { newbits = 8, netnum = 12, public = false }
  }
}
