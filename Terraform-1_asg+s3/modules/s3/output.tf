# Output for module LB
output "bucket-name" {
  value = aws_s3_bucket.bucket-for-pages.bucket
}