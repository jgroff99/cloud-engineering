output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "instance_type_used" {
  description = "Instance type selected for this environment"
  value       = aws_instance.web.instance_type
}

output "ami_id_used" {
  description = "AMI ID selected by data source"
  value       = data.aws_ami.amazon_linux.id
}

output "account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "subnet_cidrs" {
  description = "Calculated subnet CIDRs from vpc_cidr variable"
  value = {
    public_a  = cidrsubnet(var.vpc_cidr, 8, 0)
    public_b  = cidrsubnet(var.vpc_cidr, 8, 1)
    private_a = cidrsubnet(var.vpc_cidr, 8, 2)
    private_b = cidrsubnet(var.vpc_cidr, 8, 3)
  }
}
