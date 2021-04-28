# Main variables
variable "region" {
  description = "The region for infrastructure"
  type        = string
}

variable "instance_ami" {
  description = "The AMI for the instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type"
  type        = string
}

variable "ssh_port" {
  description = "SSH port for connection to the instance"
  type        = number
}

variable "http_port" {
  description = "HTTP port for connection to the instance"
  type        = number
}

variable "efs_port" {
  description = "TCP port for EFS connection to the instance"
  type        = number
}

variable "my_ip_cidr" {
  description = "A list of my IPs"
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "pr-subnets" {
  description = "IP range for private subnet 1"
  type        = list(string)
}

variable "pub-subnets" {
  description = "IP range for public subnet 1"
  type        = list(string)
}

variable "asg-desired-capacity" {
  description = "ASG - desired capacity"
  type        = number
}

variable "asg-min-size" {
  description = "ASG - min size"
  type        = number
}

variable "asg-max-size" {
  description = "ASG - max size"
  type        = number
}

variable "scal_adjust_add" {
  description = "Scaling adjustment to add instance"
  type        = number
}

variable "scal_adjust_del" {
  description = "Scaling adjustment to add instance"
  type        = number
}

variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "acl" {
  description = "Acl for the bucket"
  type        = string
}