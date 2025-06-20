provider "aws" {
  region = "us-west-2" # You can change this to your desired AWS region
}

# Define the S3 bucket
resource "aws_s3_bucket" "my_terraform_bucket" {
  bucket = "himbhavchappidi2025" # IMPORTANT: Replace with a globally unique name!
  # acl    = "private" # Removed deprecated acl argument

  tags = {
    Environment = "Development"
    Project     = "CodeBuildTerraformWebsite"
    ManagedBy   = "Terraform"
  }
}

# Configure static website hosting
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.my_terraform_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html" # Optional: specify an error page
  }
}

# Enable bucket versioning (optional)
resource "aws_s3_bucket_versioning" "my_terraform_bucket_versioning" {
  bucket = aws_s3_bucket.my_terraform_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Add a bucket policy to allow public read access for static website hosting
resource "aws_s3_bucket_policy" "my_terraform_bucket_policy" {
  bucket = aws_s3_bucket.my_terraform_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid     = "PublicReadGetObject",
        Effect  = "Allow", # IMPORTANT: Changed to Allow for website hosting
        Principal = "*",
        Action  = "s3:GetObject",
        Resource  = "${aws_s3_bucket.my_terraform_bucket.arn}/*" # Allow GetObject for all objects in the bucket
      },
      {
        Sid     = "DenyIncorrectEncryptionHeader",
        Effect  = "Deny",
        Principal = "*",
        Action  = "s3:PutObject",
        Resource  = "${aws_s3_bucket.my_terraform_bucket.arn}/*",
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      },
      {
        Sid     = "DenyUnencryptedObjectUploads",
        Effect  = "Deny",
        Principal = "*",
        Action  = "s3:PutObject",
        Resource  = "${aws_s3_bucket.my_terraform_bucket.arn}/*",
        Condition = {
          Null = {
            "s3:x-amz-server-side-encryption" = "true"
          }
        }
      }
    ]
  })
}

# Output the S3 website endpoint
output "s3_website_endpoint" {
  description = "The S3 static website endpoint"
  value       = aws_s3_bucket_website_configuration.website_config.website_endpoint
}

# Output the S3 bucket name
output "s3_bucket_name" {
  description = "The name of the S3 bucket created by Terraform"
  value       = aws_s3_bucket.my_terraform_bucket.bucket
}
