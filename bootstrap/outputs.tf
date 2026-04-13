output "state_bucket_name" {
  description = "S3 bucket name for Terraform state — update backend.hcl files with this value"
  value       = aws_s3_bucket.tf_state.bucket
}

