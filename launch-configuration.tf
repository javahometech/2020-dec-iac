resource "aws_launch_configuration" "app_lc" {
  name_prefix   = "terraform-lc-example-${local.ws}"
  image_id      = lookup(var.ami_ids, var.region)
  instance_type = "t2.micro"
  key_name = "oct-7am"
  user_data = file("apache.sh")
  security_groups = [ aws_security_group.web_sg.id ]
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "foobar3-terraform-test-${local.ws}"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  launch_configuration      = aws_launch_configuration.app_lc.name
  vpc_zone_identifier       = aws_subnet.public.*.id

  tag {
    key                 = "foo"
    value               = "bar"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "javahome-asg"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}

# scaling policy to add instances

resource "aws_autoscaling_policy" "add_instances" {
  name                   = "add-instances-${local.ws}"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_autoscaling_policy" "remove_instances" {
  name                   = "remove-instances-${local.ws}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_ge" {
  alarm_name          = "terraform-test-cpu_ge"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.add_instances.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_le" {
  alarm_name          = "terraform-test-cpu_ge"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.remove_instances.arn]
}


