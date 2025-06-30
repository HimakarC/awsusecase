terraform {
  backend "s3" {
    bucket = "terraformawsusecase"
    key    = "backend"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "my_terraform_bucket" {
  bucket = var.website_bucket_name
  website {
    index_document = "index.html"
  }

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.my_terraform_bucket.id
  block_public_acls = false
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
        Sid = "PublicReadGetObject",
        Effect = "Allow",
        Principal = "*",
        Action = "s3:*",
        Resource = "${aws_s3_bucket.my_terraform_bucket.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket.my_terraform_bucket.id]
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.my_terraform_bucket.id
  key = "index.html"
  source = "${path.module}/index.html"
  content_type = "text/html"
}

resource "aws_iam_role" "codebuild_role" {
  name = var.codebuild_role_name

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
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:*",
        "s3:*",
        "secretsmanager:GetSecretValue",
        "ssm:GetParameter"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "codedeploy_role" {
  name = var.codedeploy_role_name

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
    Statement = [{
      Effect = "Allow",
      Action = [
        "autoscaling:*",
        "ec2:DescribeInstances",
        "cloudwatch:PutMetricData"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "codepipeline_role" {
  name = var.codepipeline_role_name

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
    Statement = [{
      Effect = "Allow",
      Action = [
        "codebuild:StartBuild",
        "codedeploy:CreateDeployment",
        "s3:*"
      ],
      Resource = "*"
    }]
  })
}
