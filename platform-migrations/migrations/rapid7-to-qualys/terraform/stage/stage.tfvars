env = "stage"
ami_id = "ami-REPLACE-STAGE"
instance_type = "t3.small"

desired_capacity = 2
min_size = 1
max_size = 2

vpc_id = "vpc-stage"
subnet_ids = ["subnet-s1", "subnet-s2"]
security_group_ids = ["sg-stage"]

qualys_activation_id = ""
qualys_customer_id   = ""
tags = {
  "Project" = "migration"
  "Module"  = "rapid7-to-qualys"
}
