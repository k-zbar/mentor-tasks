region        = "eu-central-1"
instance_ami  = "ami-05ca073a83ad2f28c"
instance_type = "t2.micro"

ssh_port  = 22
http_port = 80
efs_port  = 2049

vpc_cidr_block = "10.0.0.0/16"
pr-subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
pub-subnets    = ["10.0.3.0/24", "10.0.4.0/24"]

my_ip_cidr = ["195.114.146.6/32"]

asg-desired-capacity = 2
asg-min-size         = 2
asg-max-size         = 3
scal_adjust_add      = 1
scal_adjust_del      = -1

bucket_name = "web-sites-pages"
acl         = "private"