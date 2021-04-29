# Mentor Task

## Terraform task 1
***
#### 1) Description:
##### Implement Terraform code that provision
***
* VPC
* ASG with few replicas
* On the each instances should be installed NGINX or other HTTP server, with some pages that downloaded from S3
* S3 with appropriate policy
* EC2 should have configured instance profile to get ability use s3 
* Resources should be downloaded on EFS storage
* Project should use modules and variables
* Use latest TF version
***
##### Question that you should understand after task:
***
* How IAM works?
* What is Instance profile?
* How user data works? How I can determinate that user data completed successfully?
* How EFS works, what technical restrictions it has 
* How use terraform modules?
***
#### 2) Structure of the repository:
***
.
|-- README.md
|-- main.tf
|-- modules
|   |-- asg
|   |   |-- files
|   |   |   |-- aws_iam_policy.json
|   |   |   |-- aws_iam_role.json
|   |   |   `-- user_data.tpl
|   |   |-- main.tf
|   |   `-- variables.tf
|   |-- lb
|   |   |-- main.tf
|   |   |-- output.tf
|   |   `-- variables.tf
|   |-- s3
|   |   |-- files
|   |   |   `-- index.html
|   |   |-- main.tf
|   |   |-- output.tf
|   |   `-- variables.tf
|   `-- vpc
|       |-- main.tf
|       |-- output.tf
|       `-- variables.tf
|-- output.tf
|-- provider.tf
|-- remote-state.tf
|-- terraform.tfvars
`-- variables.tf
***
#### 3) Description of the modules:
***
* asg - module that provides an Auto Scaling Group resource.
* lb - module that provides a Load Balancer resource.
* s3 - module that provides a S3 bucket resource.
* vpc - module that provides a VPC resource.
***
#### 4) Steps to reproduce:
***
1. AWS_PROFILE={YOUR_AWS_PROFILE} terraform init -var-file terraform.tfvars
2. AWS_PROFILE={YOUR_AWS_PROFILE} terraform plan -var-file terraform.tfvars
2. AWS_PROFILE={YOUR_AWS_PROFILE} terraform apply -var-file terraform.tfvars
***
#### 5) Resources that will be created:
***
```Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # aws_dynamodb_table.dynamodb-terraform-state-lock will be created
  + resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
      + arn              = (known after apply)
      + billing_mode     = "PROVISIONED"
      + hash_key         = "LockID"
      + id               = (known after apply)
      + name             = "terraform-state-lock-dynamo"
      + read_capacity    = 10
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Name" = "DynamoDB Terraform State Lock Table"
        }
      + write_capacity   = 10

      + attribute {
          + name = "LockID"
          + type = "S"
        }

      + point_in_time_recovery {
          + enabled = (known after apply)
        }

      + server_side_encryption {
          + enabled     = (known after apply)
          + kms_key_arn = (known after apply)
        }
    }

  # module.asg.data.template_file.user_data will be read during apply
  # (config refers to values not yet known)
 <= data "template_file" "user_data"  {
      + id       = (known after apply)
      + rendered = (known after apply)
      + template = <<-EOT
            #!/bin/bash
            yum -y update
            yum -y install httpd
            aws s3 cp s3://${bucket_name} /home/ec2-user --recursive
            sudo rm /var/www/html/index.html
            service httpd start
            sudo chkconfig httpd on
            efs_dns_name="${efs_dns_name}"
            sudo mount -t nfs4 $efs_dns_name:/ /var/www/html/
            sudo echo $efs_dns_name:/ /var/www/html/ nfs4 defaults,_netdev 0 0 >> /etc/fstab
            sudo cp /home/ec2-user/* /var/www/html/
        EOT
      + vars     = {
          + "bucket_name"  = "web-sites-pages"
          + "efs_dns_name" = (known after apply)
        }
    }

  # module.asg.aws_autoscaling_attachment.asg_attachment will be created
  + resource "aws_autoscaling_attachment" "asg_attachment" {
      + alb_target_group_arn   = (known after apply)
      + autoscaling_group_name = (known after apply)
      + id                     = (known after apply)
    }

  # module.asg.aws_autoscaling_group.asg will be created
  + resource "aws_autoscaling_group" "asg" {
      + arn                       = (known after apply)
      + availability_zones        = (known after apply)
      + default_cooldown          = (known after apply)
      + desired_capacity          = 2
      + force_delete              = false
      + force_delete_warm_pool    = false
      + health_check_grace_period = 300
      + health_check_type         = (known after apply)
      + id                        = (known after apply)
      + launch_configuration      = (known after apply)
      + max_size                  = 3
      + metrics_granularity       = "1Minute"
      + min_size                  = 2
      + name                      = "ASG-Web-Server"
      + protect_from_scale_in     = false
      + service_linked_role_arn   = (known after apply)
      + vpc_zone_identifier       = (known after apply)
      + wait_for_capacity_timeout = "10m"

      + tag {
          + key                 = "Name"
          + propagate_at_launch = true
          + value               = "ASG-Terraform"
        }
    }

  # module.asg.aws_autoscaling_policy.asg-policy-add will be created
  + resource "aws_autoscaling_policy" "asg-policy-add" {
      + adjustment_type         = "ChangeInCapacity"
      + arn                     = (known after apply)
      + autoscaling_group_name  = "ASG-Web-Server"
      + cooldown                = 300
      + id                      = (known after apply)
      + metric_aggregation_type = (known after apply)
      + name                    = "ASG-policy-add"
      + policy_type             = "SimpleScaling"
      + scaling_adjustment      = 1
    }

  # module.asg.aws_autoscaling_policy.asg-policy-del will be created
  + resource "aws_autoscaling_policy" "asg-policy-del" {
      + adjustment_type         = "ChangeInCapacity"
      + arn                     = (known after apply)
      + autoscaling_group_name  = "ASG-Web-Server"
      + cooldown                = 300
      + id                      = (known after apply)
      + metric_aggregation_type = (known after apply)
      + name                    = "asg-policy-del"
      + policy_type             = "SimpleScaling"
      + scaling_adjustment      = -1
    }

  # module.asg.aws_cloudwatch_metric_alarm.cloudwatch-alarm-add will be created
  + resource "aws_cloudwatch_metric_alarm" "cloudwatch-alarm-add" {
      + actions_enabled                       = true
      + alarm_actions                         = (known after apply)
      + alarm_description                     = "This metric monitors ec2 cpu utilization and add 1 unit"
      + alarm_name                            = "Add-cloudwatch-alarm"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanOrEqualToThreshold"
      + dimensions                            = {
          + "AutoScalingGroupName" = "ASG-Web-Server"
        }
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 1
      + id                                    = (known after apply)
      + metric_name                           = "CPUUtilization"
      + namespace                             = "AWS/EC2"
      + period                                = 120
      + statistic                             = "Average"
      + threshold                             = 80
      + treat_missing_data                    = "missing"
    }

  # module.asg.aws_cloudwatch_metric_alarm.cloudwatch-alarm-del will be created
  + resource "aws_cloudwatch_metric_alarm" "cloudwatch-alarm-del" {
      + actions_enabled                       = true
      + alarm_actions                         = (known after apply)
      + alarm_description                     = "This metric monitors ec2 cpu utilization"
      + alarm_name                            = "Delete-cloudwatch-alarm"
      + arn                                   = (known after apply)
      + comparison_operator                   = "LessThanOrEqualToThreshold"
      + dimensions                            = {
          + "AutoScalingGroupName" = "ASG-Web-Server"
        }
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 1
      + id                                    = (known after apply)
      + metric_name                           = "CPUUtilization"
      + namespace                             = "AWS/EC2"
      + period                                = 120
      + statistic                             = "Average"
      + threshold                             = 20
      + treat_missing_data                    = "missing"
    }

  # module.asg.aws_efs_file_system.my-nfs will be created
  + resource "aws_efs_file_system" "my-nfs" {
      + arn                     = (known after apply)
      + availability_zone_id    = (known after apply)
      + availability_zone_name  = (known after apply)
      + creation_token          = "my_nfs"
      + dns_name                = (known after apply)
      + encrypted               = (known after apply)
      + id                      = (known after apply)
      + kms_key_id              = (known after apply)
      + number_of_mount_targets = (known after apply)
      + owner_id                = (known after apply)
      + performance_mode        = (known after apply)
      + size_in_bytes           = (known after apply)
      + tags                    = {
          + "Name" = "my_nfs"
        }
      + throughput_mode         = "bursting"
    }

  # module.asg.aws_efs_mount_target.efs-mount will be created
  + resource "aws_efs_mount_target" "efs-mount" {
      + availability_zone_id   = (known after apply)
      + availability_zone_name = (known after apply)
      + dns_name               = (known after apply)
      + file_system_arn        = (known after apply)
      + file_system_id         = (known after apply)
      + id                     = (known after apply)
      + ip_address             = (known after apply)
      + mount_target_dns_name  = (known after apply)
      + network_interface_id   = (known after apply)
      + owner_id               = (known after apply)
      + security_groups        = (known after apply)
      + subnet_id              = (known after apply)
    }

  # module.asg.aws_iam_instance_profile.profile-bucket will be created
  + resource "aws_iam_instance_profile" "profile-bucket" {
      + arn         = (known after apply)
      + create_date = (known after apply)
      + id          = (known after apply)
      + name        = "profile-bucket"
      + path        = "/"
      + role        = "ec2-role-for-s3"
      + unique_id   = (known after apply)
    }

  # module.asg.aws_iam_policy.policy will be created
  + resource "aws_iam_policy" "policy" {
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "tf-iam-role-policy-copy-s3"
      + path      = "/"
      + policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:ReplicateObject",
                          + "s3:PutObject",
                          + "s3:GetObject",
                          + "s3:GetBucketTagging",
                          + "s3:GetObjectTagging",
                          + "s3:ListBucket",
                          + "s3:DeleteObject",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "arn:aws:s3:::web-sites-pages",
                          + "arn:aws:s3:::web-sites-pages/*",
                        ]
                      + Sid      = "VisualEditor0"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id = (known after apply)
    }

  # module.asg.aws_iam_role.ec2-role-for-s3 will be created
  + resource "aws_iam_role" "ec2-role-for-s3" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "ec2-role-for-s3"
      + path                  = "/"
      + unique_id             = (known after apply)

      + inline_policy {
          + name   = (known after apply)
          + policy = (known after apply)
        }
    }

  # module.asg.aws_iam_role_policy_attachment.replication will be created
  + resource "aws_iam_role_policy_attachment" "replication" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "ec2-role-for-s3"
    }

  # module.asg.aws_launch_configuration.launch-configuration will be created
  + resource "aws_launch_configuration" "launch-configuration" {
      + arn                         = (known after apply)
      + associate_public_ip_address = false
      + ebs_optimized               = (known after apply)
      + enable_monitoring           = true
      + iam_instance_profile        = "profile-bucket"
      + id                          = (known after apply)
      + image_id                    = "ami-05ca073a83ad2f28c"
      + instance_type               = "t2.micro"
      + key_name                    = "ssl-test"
      + name                        = "LC-Web-Server"
      + security_groups             = (known after apply)
      + user_data                   = "d254512eeb4857c4493c1488f52c36174ae6ae53"

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + no_device             = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # module.asg.aws_security_group.sg-private-sub will be created
  + resource "aws_security_group" "sg-private-sub" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = (known after apply)
              + self             = false
              + to_port          = 0
            },
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = (known after apply)
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "SQ for private subnet - open all ports from LB"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "SG-for-Public-SUB"
        }
      + vpc_id                 = (known after apply)
    }

  # module.asg.aws_security_group.sg-public-sub will be created
  + resource "aws_security_group" "sg-public-sub" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "NFS"
              + from_port        = 2049
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 2049
            },
          + {
              + cidr_blocks      = [
                  + "195.114.146.6/32",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "SQ for public subnet - open ssh port"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "SG-for-Public-SUB"
        }
      + vpc_id                 = (known after apply)
    }

  # module.lb.aws_lb.lb-web will be created
  + resource "aws_lb" "lb-web" {
      + arn                        = (known after apply)
      + arn_suffix                 = (known after apply)
      + dns_name                   = (known after apply)
      + drop_invalid_header_fields = false
      + enable_deletion_protection = false
      + enable_http2               = true
      + id                         = (known after apply)
      + idle_timeout               = 60
      + internal                   = false
      + ip_address_type            = (known after apply)
      + load_balancer_type         = "application"
      + name                       = "LB-Web-Server"
      + security_groups            = (known after apply)
      + subnets                    = (known after apply)
      + vpc_id                     = (known after apply)
      + zone_id                    = (known after apply)

      + subnet_mapping {
          + allocation_id        = (known after apply)
          + ipv6_address         = (known after apply)
          + outpost_id           = (known after apply)
          + private_ipv4_address = (known after apply)
          + subnet_id            = (known after apply)
        }
    }

  # module.lb.aws_lb_listener.lb-web-listener will be created
  + resource "aws_lb_listener" "lb-web-listener" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 80
      + protocol          = "HTTP"
      + ssl_policy        = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # module.lb.aws_lb_target_group.lb-tg will be created
  + resource "aws_lb_target_group" "lb-tg" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + deregistration_delay               = 300
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "LB-TG"
      + port                               = 80
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "HTTP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + target_type                        = "instance"
      + vpc_id                             = (known after apply)

      + health_check {
          + enabled             = true
          + healthy_threshold   = 4
          + interval            = 10
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "traffic-port"
          + protocol            = "HTTP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 4
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }
    }

  # module.lb.aws_security_group.sg-lb will be created
  + resource "aws_security_group" "sg-lb" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
        ]
      + name                   = "SQ for LB - open HTTP port"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "SG-FOR-LB"
        }
      + vpc_id                 = (known after apply)
    }

  # module.s3.aws_s3_bucket.bucket-for-pages will be created
  + resource "aws_s3_bucket" "bucket-for-pages" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "web-sites-pages"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Name" = "web-sites-pages"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

  # module.s3.aws_s3_bucket_object.move-objects["index.html"] will be created
  + resource "aws_s3_bucket_object" "move-objects" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + bucket_key_enabled     = (known after apply)
      + content_type           = (known after apply)
      + etag                   = "480f8c6ba7b824cd8132f69ce757205a"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "index.html"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "modules/s3/files/index.html"
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # module.vpc.aws_eip.eip-nat-gateway will be created
  + resource "aws_eip" "eip-nat-gateway" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + vpc                  = (known after apply)
    }

  # module.vpc.aws_internet_gateway.igw-1 will be created
  + resource "aws_internet_gateway" "igw-1" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "1-IGW"
        }
      + vpc_id   = (known after apply)
    }

  # module.vpc.aws_nat_gateway.gw-1 will be created
  + resource "aws_nat_gateway" "gw-1" {
      + allocation_id        = (known after apply)
      + id                   = (known after apply)
      + network_interface_id = (known after apply)
      + private_ip           = (known after apply)
      + public_ip            = (known after apply)
      + subnet_id            = (known after apply)
      + tags                 = {
          + "Name" = "1-GW-NAT"
        }
    }

  # module.vpc.aws_route.public-route-1 will be created
  + resource "aws_route" "public-route-1" {
      + destination_cidr_block = "0.0.0.0/0"
      + gateway_id             = (known after apply)
      + id                     = (known after apply)
      + instance_id            = (known after apply)
      + instance_owner_id      = (known after apply)
      + network_interface_id   = (known after apply)
      + origin                 = (known after apply)
      + route_table_id         = (known after apply)
      + state                  = (known after apply)
    }

  # module.vpc.aws_route_table.private-route-1 will be created
  + resource "aws_route_table" "private-route-1" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + carrier_gateway_id         = ""
              + cidr_block                 = "0.0.0.0/0"
              + destination_prefix_list_id = ""
              + egress_only_gateway_id     = ""
              + gateway_id                 = (known after apply)
              + instance_id                = ""
              + ipv6_cidr_block            = ""
              + local_gateway_id           = ""
              + nat_gateway_id             = ""
              + network_interface_id       = ""
              + transit_gateway_id         = ""
              + vpc_endpoint_id            = ""
              + vpc_peering_connection_id  = ""
            },
        ]
      + tags             = {
          + "Name" = "1_Private_route"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table_association.to_private-1 will be created
  + resource "aws_route_table_association" "to_private-1" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.to_private-2 will be created
  + resource "aws_route_table_association" "to_private-2" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_subnet.private-subnets[0] will be created
  + resource "aws_subnet" "private-subnets" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-central-1a"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.1.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "Private_subnet"
        }
      + tags_all                        = {
          + "Name" = "Private_subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # module.vpc.aws_subnet.private-subnets[1] will be created
  + resource "aws_subnet" "private-subnets" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-central-1b"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.2.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "Private_subnet"
        }
      + tags_all                        = {
          + "Name" = "Private_subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # module.vpc.aws_subnet.public-subnets[0] will be created
  + resource "aws_subnet" "public-subnets" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-central-1a"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.3.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = true
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "Public_subnet"
        }
      + tags_all                        = {
          + "Name" = "Public_subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # module.vpc.aws_subnet.public-subnets[1] will be created
  + resource "aws_subnet" "public-subnets" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-central-1b"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.0.4.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = true
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "Public_subnet"
        }
      + tags_all                        = {
          + "Name" = "Public_subnet"
        }
      + vpc_id                          = (known after apply)
    }

  # module.vpc.aws_vpc.my_vpc will be created
  + resource "aws_vpc" "my_vpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "MY-VPC"
        }
      + tags_all                         = {
          + "Name" = "MY-VPC"
        }
    }

Plan: 34 to add, 0 to change, 0 to destroy.
```
***