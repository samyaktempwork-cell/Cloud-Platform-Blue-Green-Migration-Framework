output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "asg_blue_name" {
  value = module.asg.asg_blue_name
}

output "asg_green_name" {
  value = module.asg.asg_green_name
}

output "instance_profile" {
  value = module.iam_roles.instance_profile_name
}
