env_name  = "dev"

role_arn  = "arn:aws:iam::<DEV_ACCOUNT_ID>:role/TerraformRole"

cidr_block = "10.10.0.0/16"

ami_blue  = "ami-dev-blue"
ami_green = "ami-dev-green"

allowed_http_cidrs = ["0.0.0.0/0"]
allowed_ssh_cidrs  = []

desired_capacity_blue  = 2
desired_capacity_green = 0

chef_role = "app_node"