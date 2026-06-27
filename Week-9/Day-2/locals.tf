locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    AccountId   = data.aws_caller_identity.current.account_id
    Owner       = "jordan"
  }
}
