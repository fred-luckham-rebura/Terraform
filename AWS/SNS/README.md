# EC2 State Change Alert

This template creates a region sepcific EventBridge trigger and SNS topic, which can alert and endpoint when an EC2 instances changes state. For example, if someone starts creating new ones in your account, or changing configurations, you will be alerted. 

Simply add and endpoint to the "aws_sns_topic_subscription" resource. 