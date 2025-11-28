resource "aws_launch_template" "blue" {
  name_prefix   = "${var.app_name}-blue-"
  image_id      = var.ami_blue
  instance_type = var.instance_type

  user_data = base64encode(data.templatefile.chef_userdata)

  vpc_security_group_ids = [var.app_security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name  = "${var.app_name}-blue"
      Color = "blue"
    })
  }
}

resource "aws_launch_template" "green" {
  name_prefix   = "${var.app_name}-green-"
  image_id      = var.ami_green
  instance_type = var.instance_type

  user_data = base64encode(data.templatefile.chef_userdata)

  vpc_security_group_ids = [var.app_security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name  = "${var.app_name}-green"
      Color = "green"
    })
  }
}

resource "aws_autoscaling_group" "blue" {
  name                      = "${var.app_name}-blue-asg"
  desired_capacity          = var.desired_capacity_blue
  max_size                  = var.max_size
  min_size                  = var.min_size
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_blue_arn]

  tag {
    key                 = "Name"
    value               = "${var.app_name}-blue"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "green" {
  name                      = "${var.app_name}-green-asg"
  desired_capacity          = var.desired_capacity_green
  max_size                  = var.max_size
  min_size                  = var.min_size
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_green_arn]

  tag {
    key                 = "Name"
    value               = "${var.app_name}-green"
    propagate_at_launch = true
  }
}

data "templatefile" "chef_userdata" {
  template = "${path.module}/templates/chef_bootstrap.sh.tpl"

  vars = {
    chef_role = var.chef_role
  }
}
