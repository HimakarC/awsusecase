provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "static_site" {
  bucket = "my-static-site-bucket-123"
  acl = "public-read"
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Add policies, CodeBuild project, and CodePipeline here...
