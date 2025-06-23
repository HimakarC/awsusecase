terraform{
  backend "s3" {
    bucket = "terraformawsusecase"
    key = "backend"
    region = "us-west-2"
  }
}
provider "aws" {
  region = "us-west-2" # You can change this to your desired AWS region
}

# Define the S3 bucket
resource "aws_s3_bucket" "my_terraform_bucket" {
  bucket = "himbhavchappidi2025" # IMPORTANT: Replace with a globally unique name!
  # acl    = "public-read" # Removed deprecated acl argument

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Environment = "Development"
    Project     = "CodeBuildTerraformWebsite"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.my_terraform_bucket.id
  block_public_acls  = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.my_terraform_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:*",
        Resource  = "${aws_s3_bucket.my_terraform_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.my_terraform_bucket.id
  key = "index.html"
  source = "${path.module}/index.html" # Assumes index.html is in the same folder as your .tf files
  content_type = "text/html"
}

# CodeBuild Role
resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildServiceRole"

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

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "CodeBuildPolicy"
  role   = aws_iam_role.codebuild_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:*",
          "s3:*",
          "secretsmanager:GetSecretValue",
          "ssm:GetParameter"
        ],
        Resource = "*"
      }
    ]
  })
}

# CodeDeploy Role
resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codedeploy.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codedeploy_policy" {
  name   = "CodeDeployPolicy"
  role   = aws_iam_role.codedeploy_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "autoscaling:*",
          "ec2:DescribeInstances",
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      }
    ]
  })
}

# CodePipeline Role
resource "aws_iam_role" "codepipeline_role" {
  name = "CodePipelineServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "CodePipelinePolicy"
  role   = aws_iam_role.codepipeline_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codedeploy:CreateDeployment",
          "s3:*"
        ],
        Resource = "*"
      }
    ]
  })
}
