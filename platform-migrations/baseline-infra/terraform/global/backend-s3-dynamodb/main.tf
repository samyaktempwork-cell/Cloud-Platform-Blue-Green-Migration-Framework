terraform {
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = var.aws_region
}

# S3 Bucket for Terraform Remote State
resource "aws_s3_bucket" "tf_state" {
  bucket = var.backend_bucket

  force_destroy = false

  tags = merge(
    var.tags,
    {
      Name        = var.backend_bucket
      Purpose     = "Terraform-Remote-State"
      Environment = "shared-services"
    }
  )
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.tags,
    {
      Name        = var.lock_table
      Purpose     = "Terraform-State-Locking"
      Environment = "shared-services"
    }
  )
}
