resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Project	= "week-9-terraform"
  }
}
