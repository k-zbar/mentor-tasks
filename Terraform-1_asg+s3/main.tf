# Module for VPC with 2 private and 2 public subnets
module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  pr-subnets     = var.pr-subnets
  pub-subnets    = var.pub-subnets
}

# Module for ASG with 2 desired instances and LB between them
module "asg" {
  source               = "./modules/asg"
  my_vpc               = module.vpc.my_vpc
  my_ip_cidr           = var.my_ip_cidr
  instance_ami         = var.instance_ami
  instance_type        = var.instance_type
  gw-1                 = module.vpc.gw-1
  pr-subnets           = module.vpc.pr-subnets
  pub-subnets          = module.vpc.pub-subnets
  asg-desired-capacity = var.asg-desired-capacity
  asg-min-size         = var.asg-min-size
  asg-max-size         = var.asg-max-size
  scal_adjust_add      = var.scal_adjust_add
  scal_adjust_del      = var.scal_adjust_del
  ssh_port             = var.ssh_port
  http_port            = var.http_port
  efs_port             = var.efs_port
  lb-tg                = module.lb.lb-tg
  sg-lb                = module.lb.sg-lb
  bucket-name          = var.bucket_name
}

# Module for LB
module "lb" {
  source      = "./modules/lb"
  vpc-1       = module.vpc.my_vpc
  pub-subnets = module.vpc.pub-subnets
  http-port   = var.http_port
}

# Module for S3
module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  acl         = var.acl
  region      = var.region
}