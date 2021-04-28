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