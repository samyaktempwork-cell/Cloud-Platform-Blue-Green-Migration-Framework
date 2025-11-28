env_name  = "prod"

role_arn  = "arn:aws:iam::<PROD_ACCOUNT_ID>:role/TerraformRole"

cidr_block = "10.30.0.0/16"

ami_blue  = "ami-prod-blue"
ami_green = "ami-prod-green"

allowed_http_cidrs = ["10.0.0.0/16"]  # Stricter
allowed_ssh_cidrs  = []

desired_capacity_blue  = 4
desired_capacity_green = 0

chef_role = "app_node"