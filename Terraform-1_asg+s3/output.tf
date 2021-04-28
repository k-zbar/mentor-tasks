# Output public subnets
output "pub_subnets" {
  value = module.vpc.pub-subnets
}

# Output private subnets
output "pr_subnets" {
  value = module.vpc.pr-subnets
}

# Output bucket name
output "bucket_name" {
  value = module.s3.bucket-name
}

# Output DNS-name for LB
output "lb-web" {
  value = module.lb.lb-web
}