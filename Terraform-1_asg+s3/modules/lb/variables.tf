# Local variables for module LB
variable "vpc-1" {}

variable "pub-subnets" {}

variable "http-port" {}

variable "protocol" {
  default = "HTTP"
}

# The number of consecutive health checks successes required before considering an unhealthy target healthy
variable "healthy-threshold" {
  default = 4
}

# The number of consecutive health check failures required before considering the target unhealthy
variable "unhealthy_threshold" {
  default = 4
}

# The approximate amount of time, in seconds, between health checks of an individual target
variable "interval" {
  default = 10
}