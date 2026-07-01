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

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "security_group_rules" {
  description = "Ingress rules for the app security group — key becomes the rule identifier"
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = {
    "https" = {
      description = "HTTPS from VPC"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
    "http" = {
      description = "HTTP from VPC"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  }
}

variable "app_name" {
  description = "Application name used in user data and instance tags"
  type        = string
  default     = "web"
}
