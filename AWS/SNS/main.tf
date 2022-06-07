terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

# Provider
provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

# Create SNS topic
resource "aws_sns_topic" "ec2_launch_alert" {
  name = "EC2LaunchAlert"
}

# Create SNS subscription and endpoint
resource "aws_sns_topic_subscription" "ec2_launch_alert_subscription" {
  topic_arn = aws_sns_topic.ec2_launch_alert.arn
  protocol  = "email"
  endpoint  = ""
}

# Create EventBridge target
resource "aws_cloudwatch_event_target" "sns" {
    rule = aws_cloudwatch_event_rule.ec2_launch.name
    target_id = "SendToSNS"
    arn = aws_sns_topic.ec2_launch_alert.arn
    input_transformer {
        input_paths = {
            account = "$.account",
            instance_id = "$.detail.instance-id",
            region = "$.region",
            state = "$.detail.state",
            time = "$.time"
        }
        input_template = "\"At <time>, the status of your EC2 instance <instance_id> on account <account> in the AWS Region <region> has changed to <state>.\""
    } 
}

# Create EventBridge rule
resource "aws_cloudwatch_event_rule" "ec2_launch" {
    name = "capture"
    event_pattern = <<EOF
    {
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"]
    }
    EOF
}