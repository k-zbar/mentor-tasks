# Local variables for module ASG
variable "my_vpc" {}

variable "my_ip_cidr" {}

variable "instance_ami" {}

variable "instance_type" {}

variable "gw-1" {}

variable "pr-subnets" {}

variable "pub-subnets" {}

variable "asg-desired-capacity" {}

variable "asg-min-size" {}

variable "asg-max-size" {}

variable "cooldown" {
  default = "300"
}

# The number of instances by which to scale
variable "scal_adjust_add" {}

variable "scal_adjust_del" {}

variable "evaluation_periods" {
  default = "1"
}

variable "period" {
  default = "120"
}

variable "threshold_up" {
  default = "80"
}

variable "threshold_down" {
  default = "20"
}

variable "ssh_port" {}

variable "http_port" {}

variable "efs_port" {}

variable "bucket-name" {}

variable "lb-tg" {}

variable "sg-lb" {}