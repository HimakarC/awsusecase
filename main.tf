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
