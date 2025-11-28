data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_ec2_role" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-role"
  })
}

# Attach SSM + CloudWatch (basic management & diagnostics)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.app_ec2_role.name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-instance-profile"
  })
}

resource "aws_iam_policy" "chef_runtime_policy" {
  name        = "${var.name_prefix}-chef-runtime-policy"
  description = "Permissions required for Chef & SSM agents on EC2"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:*",
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "chef_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.chef_runtime_policy.arn
}