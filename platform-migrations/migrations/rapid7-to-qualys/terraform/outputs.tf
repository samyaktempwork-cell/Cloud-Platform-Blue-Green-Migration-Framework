# outputs.tf - helpful outputs

output "asg_name" {
  description = "ASG name created for the migration"
  value       = try(module.migration_asg.asg_name, "")
}

output "launch_template_id" {
  description = "Launch Template ID used by migration"
  value       = try(module.migration_asg.launch_template_id, "")
}

output "instance_profile_name" {
  description = "IAM instance profile attached to migration instances"
  value       = aws_iam_instance_profile.migration_profile.name
}
