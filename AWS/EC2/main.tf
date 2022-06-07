terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

locals {
  raw_data = file("CloudWatch/cloudwatch-agent-config.json")
}

resource "aws_instance" "app_server" {
  ami                  = "ami-0d729d2846a86a9e7"
  instance_type        = "t2.micro"
  iam_instance_profile = "cloudwatch-test-monitoring"
  user_data            = <<EOF
Content-Type: multipart/mixed; boundary="===============BOUNDARY=="
MIME-Version: 1.0

--===============BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="standard_userdata.txt"

#!/bin/bash
yum -y install amazon-cloudwatch-agent
var='${local.raw_data}'
echo $var > config.json
mv config.json /opt/aws/amazon-cloudwatch-agent/bin/
mkdir -p /usr/share/collectd/
touch /usr/share/collectd/types.db
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

--===============BOUNDARY==
MIME-Version: 1.0
Content-Type: text/cloud-boothook; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="boothook.txt"

#cloud-boothook
#echo 'OPTIONS="$${OPTIONS} --storage-opt dm.basesize=50G"' >> /etc/sysconfig/docker

--===============BOUNDARY==--
EOF

  tags = {
    Name = "CloudWatchAutoInstallTestInstance"
  }
}