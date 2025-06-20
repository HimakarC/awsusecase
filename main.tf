provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "static_site" {
  bucket = "my-static-site-bucket-123"
  acl = "public-read"
}

# Add policies, CodeBuild project, and CodePipeline here...
