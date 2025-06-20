provider "aws" {Add commentMore actions
  region = "us-west-2" # You can change this to your desired AWS region
}

# Define the S3 bucket with website configuration
resource "aws_s3_bucket" "my_terraform_bucket" {
  bucket = "my-unique-codebuild-s3-website-2025-06-20" # IMPORTANT: S3 bucket names must be globally unique. Change this to something unique!
  # acl = "public-read" # Not recommended directly. Use bucket policy instead for granular control.

  website {
    index_document = "index.html"
  }

  tags = {
    Environment = "Development"
    Project     = "CodeBuildTerraformWebsite"
    ManagedBy   = "Terraform"
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
        Sid       = "PublicReadGetObject",
        Effect    = "Allow", # IMPORTANT: Changed to Allow for website hosting
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.my_terraform_bucket.arn}/*" # Allow GetObject for all objects in the bucket
      }
    ]
  })
}

# Output the S3 website endpoint
output "s3_website_endpoint" {
  description = "The S3 static website endpoint"
  value       = aws_s3_bucket.my_terraform_bucket.website_endpoint
}

# Output the S3 bucket name
output "s3_bucket_name" {
  description = "The name of the S3 bucket created by Terraform"
  value       = aws_s3_bucket.my_terraform_bucket.bucketAdd commentMore actions
}
