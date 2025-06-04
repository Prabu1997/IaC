resource "aws_launch_template" "instance_template" {
  name_prefix =   "firewall-instance"
  image_id = var.ami_image_id
  instance_type = var.instance_type
  key_name = Var.key_name
  network_interfaces {
    associate_public_ip_address = true
    security_groups = var.security_groups_id
    description = "Firewall ENI"
  }
  monitoring {
    enabled = true
  }
  iam_instance_profile {
    arn = var.iam_instance_role
  }
  tag_specifications {
    tags = {
      Name = var.instance_name
    }
  }

  user_data = filebase64("${path.module}/user/user_data.yml") # Passing user data it help to keep the instance ready to use 
  lifecycle {
    create_before_destroy = true
  }
}

### Auto scaling group ###

resource "aws_autoscaling_group" "instance_auto_scale_group" {
  name = "Instance_auto_scale_group"
    availability_zones = var.availability_zone
    desired_capacity = var.desired_capacity
    max_size = var.max_size
    min_size = var.min_size
    vpc_zone_identifier = toset(tolist(var.subnet_ids))
    target_group_arns = []
    health_check_type = var.asg_health_check_type
  launch_template {
    id = aws_launch_template.instance_template.id
    version = "$latest"
  }
}

## Scaling POlicy ###
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  cooldown               = "300"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.instance_auto_scale_group.name
}

# CloudWatch Alarms for Scaling
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70 # Change this threshold as needed
  alarm_description   = "This alarm triggers when CPU exceeds 70%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.instance_auto_scale_group.name
    }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_in.arn]
}

##### Gateway load balance for your firewall ####
# Gateway Load Balancer
resource "aws_lb" "gateway_lb" {
  name                             = "asg-gateway-lb"
  internal                         = false
  load_balancer_type               = "gateway"
  enable_cross_zone_load_balancing = true
  dynamic "subnet_mapping" {
    for_each = var.subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
    # subnet_id = toset(tolist(var.subnet_ids))
  }
  tags = {
    Name            = "gateway-load-balancer"
  }
}

resource "aws_lb_target_group" "gwlb-target" {
  name        = "Firewall-LB"
  port        = 6081
  protocol    = "GENEVE"
  vpc_id      = tostring(var.vpc_id)
  target_type = "instance"

  health_check {
    port     = 22
    protocol = "TCP"
  }
}


resource "aws_lb_listener" "gwlb-listener" {
  load_balancer_arn = aws_lb.gateway_lb.arn
  default_action {
    target_group_arn = aws_lb_target_group.gwlb-target.arn
    type             = "forward"
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "tager_group_attachement" {
  autoscaling_group_name = aws_autoscaling_group.instance_auto_scale_group.name
  lb_target_group_arn    = aws_lb_target_group.gwlb-target.arn
}
