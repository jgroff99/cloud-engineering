output "bucket_arn" {
  value       = aws_s3_bucket.my_bucket.arn
  description = "ARN of the created S3 bucket"
}

output "bucket_name" {
  value       = aws_s3_bucket.my_bucket.bucket
  description = "Name of the created S3 bucket"
}
