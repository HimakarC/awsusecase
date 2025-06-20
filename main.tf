provider "aws" {
  region = "us-west-2" # You can change this to your desired AWS region
}

# Define the S3 bucket
resource "aws_s3_bucket" "my_terraform_bucket" {
  bucket = "my-unique-codebuild-s3-bucket-2025-06-20" # IMPORTANT: S3 bucket names must be globally unique. Change this to something unique!
  acl    = "private" # Recommended for most use cases

  tags = {
    Environment = "Development"
    Project     = "CodeBuildTerraform"
    ManagedBy   = "Terraform"
  }
}

# Optional: Enable bucket versioning
resource "aws_s3_bucket_versioning" "my_terraform_bucket_versioning" {
  bucket = aws_s3_bucket.my_terraform_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Optional: Add a bucket policy (e.g., to prevent public access)
resource "aws_s3_bucket_policy" "my_terraform_bucket_policy" {
  bucket = aws_s3_bucket.my_terraform_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "DenyIncorrectEncryptionHeader",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.my_terraform_bucket.arn}/*",
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      },
      {
        Sid       = "DenyUnencryptedObjectUploads",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.my_terraform_bucket.arn}/*",
        Condition = {
          Null = {
            "s3:x-amz-server-side-encryption" = "true"
          }
        }
      },
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.my_terraform_bucket.arn}/*",
        Condition = {
          "StringEquals" = {
            "s3:x-amz-acl": "public-read"
          }
        }
      }
    ]
  })
}

# Output the bucket name
output "s3_bucket_name" {
  description = "The name of the S3 bucket created by Terraform"
  value       = aws_s3_bucket.my_terraform_bucket.bucket
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket created by Terraform"
  value       = aws_s3_bucket.my_terraform_bucket.arn
}
