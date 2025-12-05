env = "dev"
ami_id = "ami-REPLACE-WITH-BASELINE-AMI"
instance_type = "t3.small"

desired_capacity = 1
min_size = 1
max_size = 1

vpc_id = "vpc-REPLACE"
subnet_ids = ["subnet-aaa", "subnet-bbb"]
security_group_ids = ["sg-REPLACE"]

qualys_activation_id = ""
qualys_customer_id   = ""
tags = {
  "Project" = "migration"
  "Module"  = "rapid7-to-qualys"
}
