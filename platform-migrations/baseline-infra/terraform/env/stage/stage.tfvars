env_name  = "stage"

role_arn  = "arn:aws:iam::<STAGE_ACCOUNT_ID>:role/TerraformRole"

cidr_block = "10.20.0.0/16"

ami_blue  = "ami-stage-blue"
ami_green = "ami-stage-green"

allowed_http_cidrs = ["10.0.0.0/8"]
allowed_ssh_cidrs  = []

desired_capacity_blue  = 2
desired_capacity_green = 0

chef_role = "app_node"