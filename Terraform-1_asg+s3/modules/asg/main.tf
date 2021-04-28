# Mention availability zones for infrastructure
data "aws_availability_zones" "all" {}

//# Take parameter from SSM
//data "aws_ssm_parameter" "pub_key" {
//  name = "ssh-key"
//}
//
//# Use SSM parameter as a ssh-key
//resource "aws_key_pair" "pub-key-ssm" {
//  public_key = data.aws_ssm_parameter.pub_key.value
//}

//# Create VM to check web sites
//resource "aws_instance" "Pub_EC2_first_vpc" {
//  ami                    = var.instance_ami
//  instance_type          = var.instance_type
//  vpc_security_group_ids = [aws_security_group.sg-public-sub.id]
//  subnet_id              = var.pub-subnets[0]
//  //  key_name               = aws_key_pair.pub-key-ssm.id
//  key_name             = "ssl-test"
//  iam_instance_profile = aws_iam_instance_profile.profile-bucket.name
//  user_data            = data.template_file.user_data.rendered
//
//  depends_on = [aws_efs_mount_target.efs-mount]
//}

resource "aws_iam_instance_profile" "profile-bucket" {
  name = "profile-bucket"
  role = aws_iam_role.ec2-role-for-s3.name
}

resource "aws_iam_role" "ec2-role-for-s3" {
  name               = "ec2-role-for-s3"
  path               = "/"
  assume_role_policy = file("${path.module}/files/aws_iam_role.json")
}

resource "aws_iam_policy" "policy" {
  name   = "tf-iam-role-policy-copy-s3"
  policy = data.template_file.iam_policy.rendered
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.ec2-role-for-s3.name
  policy_arn = aws_iam_policy.policy.arn
}

# Create Template file for user data
data "template_file" "user_data" {
  template = file("${path.module}/files/user_data.tpl")

  vars = {
    bucket_name  = var.bucket-name
    efs_dns_name = aws_efs_file_system.my-nfs.dns_name
  }
}

# Create Template file for policy
data "template_file" "iam_policy" {
  template = file("${path.module}/files/aws_iam_policy.json")

  vars = {
    bucket_name = var.bucket-name
  }
}

# Create LC to configure VMs in ASG
resource "aws_launch_configuration" "launch-configuration" {
  name                 = "LC-Web-Server"
  image_id             = var.instance_ami
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.sg-private-sub.id]
  user_data            = file("${path.module}/files/user_data.tpl")
  key_name             = "ssl-test"
  iam_instance_profile = aws_iam_instance_profile.profile-bucket.name
  //  key_name        = aws_key_pair.pub-key-ssm.id

  # Create instances before destroy
  lifecycle {
    create_before_destroy = true
  }
  # Run after NAT Gateway
  depends_on = [var.gw-1]
}

# Create ASG for two web sites
resource "aws_autoscaling_group" "asg" {
  name                 = "ASG-Web-Server"
  launch_configuration = aws_launch_configuration.launch-configuration.id
  vpc_zone_identifier  = var.pr-subnets
  desired_capacity     = var.asg-desired-capacity
  min_size             = var.asg-min-size
  max_size             = var.asg-max-size

  tag {
    key                 = "Name"
    value               = "ASG-Terraform"
    propagate_at_launch = true
  }
}

# Create ASG policy to add VM
resource "aws_autoscaling_policy" "asg-policy-add" {
  name                   = "ASG-policy-add"
  scaling_adjustment     = var.scal_adjust_add
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.cooldown
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# Create ASG policy to del VM
resource "aws_autoscaling_policy" "asg-policy-del" {
  name                   = "asg-policy-del"
  scaling_adjustment     = var.scal_adjust_del
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.cooldown
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# Create alarm to add VM
resource "aws_cloudwatch_metric_alarm" "cloudwatch-alarm-add" {
  alarm_name          = "Add-cloudwatch-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold_up
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization and add 1 unit"
  alarm_actions     = [aws_autoscaling_policy.asg-policy-add.arn]
}

# Create alarm to del VM
resource "aws_cloudwatch_metric_alarm" "cloudwatch-alarm-del" {
  alarm_name          = "Delete-cloudwatch-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold_down
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.asg-policy-del.arn]
}

# Create attachment with ASG and LB target group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  alb_target_group_arn   = var.lb-tg
}

# Create SG for public subnets
resource "aws_security_group" "sg-public-sub" {
  name   = "SQ for public subnet - open ssh port"
  vpc_id = var.my_vpc
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.my_ip_cidr
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "NFS"
    from_port   = var.efs_port
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-for-Public-SUB"
  }
}

# Creating EFS
resource "aws_efs_file_system" "my-nfs" {
  depends_on     = [aws_security_group.sg-public-sub, ]
  creation_token = "my_nfs"

  tags = {
    Name = "my_nfs"
  }
}

# Mounting EFS
resource "aws_efs_mount_target" "efs-mount" {
  depends_on      = [aws_efs_file_system.my-nfs, ]
  file_system_id  = aws_efs_file_system.my-nfs.id
  subnet_id       = var.pub-subnets[0]
  security_groups = [aws_security_group.sg-public-sub.id]
}

# Create open SG from LB
resource "aws_security_group" "sg-private-sub" {
  name   = "SQ for private subnet - open all ports from LB"
  vpc_id = var.my_vpc

  ingress {
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-public-sub.id]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.sg-lb]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-for-Public-SUB"
  }
}