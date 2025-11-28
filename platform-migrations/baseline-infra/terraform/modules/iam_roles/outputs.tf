output "ec2_role_name" {
  value = aws_iam_role.app_ec2_role.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.app_profile.name
}
