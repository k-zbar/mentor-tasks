# Create an S3 bucket to store the state file in
# Using dynamodb_table to lock the state file using DynamoDB (!A table should exist first)
terraform {
  backend "s3" {
    bucket  = "my.terraform5.bucket"
    key     = "Terraform-2/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
    //dynamodb_table = "terraform-state-lock-dynamo"
  }
}

# Create a DynamoDB table for locking the state file
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 10
  write_capacity = 10

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}