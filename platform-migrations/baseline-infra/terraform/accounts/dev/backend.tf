terraform {
  backend "s3" {
    bucket         = "YOUR_BACKEND_BUCKET"       # Replace after backend creation
    key            = "dev/base-infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tf-state-locks"
    encrypt        = true
  }
}
