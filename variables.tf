variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "website_bucket_name" {
  description = "Name of the S3 bucket for website hosting"
  type        = string
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "CodeBuildTerraformWebsite"
    ManagedBy   = "Terraform"
  }
}

variable "codebuild_role_name" {
  default = "CodeBuildServiceRole"
}

variable "codedeploy_role_name" {
  default = "CodeDeployServiceRole"
}

variable "codepipeline_role_name" {
  default = "CodePipelineServiceRole"
}
