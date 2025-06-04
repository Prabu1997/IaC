### Creating a Launch Teamplate ##

resource "aws_launch_template" "http_application" {
  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = 20
    }
  }
ebs_optimized = true
instance_type = var.instance_type
key_name = var.key_name
iam_instance_profile {
  arn = var.iam_instance_profile
}
image_id = var.ami_image_id
name_prefix = ""
monitoring {
  enabled = true
}
network_interfaces {
  associate_public_ip_address = true
}
placement {
  availability_zone = var.availability_zone
}
vpc_security_group_ids = toset(var.vpc_security_group_ids)
tag_specifications {
  tags = {
    Name = var.template_name
  }
}
user_data = filebase64("${path.module}/init.sh")

lifecycle {
  create_before_destroy = true
}
}


##### Auto Scaling Group ##########

resource "aws_autoscaling_group" "http_instance_auto_scale_group" {
    name = "Instance_auto_scale_group"
    availability_zones = var.availability_zones
    desired_capacity = var.desired_capacity
    max_size = var.max_size
    min_size = var.min_size
    vpc_zone_identifier = toset(tolist(var.subnet_ids))
    target_group_arns = []
    health_check_type = var.asg_health_check_type
  launch_template {
    id = aws_launch_template.http_application.id
    version = aws_launch_template.http_application.latest_version
  }
}

## Simple Scaling POlicy ###
resource "aws_autoscaling_policy" "scale_in_event" {
  name                   = "scale-in"
  cooldown               = 300
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.http_instance_auto_scale_group.name
}

resource "aws_autoscaling_policy" "scale_down_event" {
  name                   = "scale_down_policy"
  autoscaling_group_name = aws_autoscaling_group.http_instance_auto_scale_group.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1
  cooldown               = 300
}

# CloudWatch Alarms for Scaling
resource "aws_cloudwatch_metric_alarm" "high_cpu_event" {
  alarm_name          = "high-cpu-alarm"
  alarm_description   = "Scale up ASG when average CPU utilization is above 70%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70 # Change this threshold as needed

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.http_instance_auto_scale_group.name
    }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_in_event.arn]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_event" {
  alarm_name          = "low-cpu-alarm"
  alarm_description   = "Scale down ASG when average CPU utilization is below 50%"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 2
  threshold           = 50
  comparison_operator = "LessThanThreshold"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.http_instance_auto_scale_group.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.scale_down_event.arn]
}

### ADD Servers into Target group ####

resource "aws_autoscaling_attachment" "tager_group_attachement" {
  autoscaling_group_name = aws_autoscaling_group.http_instance_auto_scale_group.name
  lb_target_group_arn    = var.aws_elb_arn
}
