# Output for module LB
output "lb-web" {
  value = aws_lb.lb-web.dns_name
}

output "lb-tg" {
  value = aws_lb_target_group.lb-tg.arn
}

output "sg-lb" {
  value = aws_security_group.sg-lb.id
}