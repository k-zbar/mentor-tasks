# Specify special region and credentials for AWS account
provider "aws" {
  region = var.region
  //  shared_credentials_file = "%USERPROFILE%/.aws/credentials"
}