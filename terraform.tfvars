aws_region = "us-west-2"


website_bucket_name = "himbhavchappidi"

tags = {
  Environment = "Development"
  Project     = "StaticWebsite"
  Owner       = "YourName"
}

codebuild_role_name   = "CodeBuildRole"
codedeploy_role_name  = "CodeDeployRole"
codepipeline_role_name = "CodePipelineRole"
