output "state_bucket_name" {
  description = "S3 bucket name for Terraform state — update backend.hcl files with this value"
  value       = aws_s3_bucket.tf_state.bucket
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.tf_state_lock.name
}
