output "instance_id" {
  description = "s3 bucket versioning"
  value       = aws_s3_bucket_versioning.terraform_bucket_versioning
}

output "instance_public_ip" {
  description = "dynamodb's lock"
  value       = aws_dynamodb_table.terraform_locks
}
