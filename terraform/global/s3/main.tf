terraform {
  required_version = ">= 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

###############################################################################
# VARIABLES
###############################################################################

variable "aws_region" {
  type        = string
  description = "AWS region for Terraform state resources"
  default     = "us-west-2"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name"
  default = "ccon-tfstate"
}

###############################################################################
# S3 BUCKET
###############################################################################

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  tags = {
    Name      = var.bucket_name
    Purpose   = "terraform-state"
    ManagedBy = "terraform"
  }
  lifecycle {
    prevent_destroy = true
  }
}

###############################################################################
# BLOCK ALL PUBLIC ACCESS
###############################################################################

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

###############################################################################
# ENABLE VERSIONING
###############################################################################

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

###############################################################################
# SERVER-SIDE ENCRYPTION
###############################################################################

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = true
  }
}

###############################################################################
# ENFORCE TLS
###############################################################################

data "aws_iam_policy_document" "terraform_state_tls" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.terraform_state_tls.json
}

###############################################################################
# OPTIONAL: CLEANUP OLD VERSIONS
###############################################################################

# resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id

#   rule {
#     id     = "cleanup-old-versions"
#     status = "Enabled"

#     noncurrent_version_expiration {
#       noncurrent_days = 90
#     }
#   }
# }

###############################################################################
# OUTPUTS
###############################################################################

output "terraform_state_bucket" {
  value = aws_s3_bucket.terraform_state.bucket
}