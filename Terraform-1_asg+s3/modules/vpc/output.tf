# Output for module VPC
output "my_vpc" {
  value = aws_vpc.my_vpc.id
}

output "gw-1" {
  value = aws_nat_gateway.gw-1.id
}

output "pr-subnets" {
  value = aws_subnet.private-subnets.*.id
}

output "pub-subnets" {
  value = aws_subnet.public-subnets.*.id
}