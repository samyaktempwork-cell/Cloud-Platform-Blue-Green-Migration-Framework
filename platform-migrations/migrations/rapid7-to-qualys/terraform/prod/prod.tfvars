env = "prod"
ami_id = "ami-REPLACE-PROD"
instance_type = "t3.medium"

desired_capacity = 3
min_size = 2
max_size = 5

vpc_id = "vpc-prod"
subnet_ids = ["subnet-p1", "subnet-p2"]
security_group_ids = ["sg-prod"]

qualys_activation_id = ""
qualys_customer_id   = ""
tags = {
  "Project" = "migration"
  "Module"  = "rapid7-to-qualys"
}
