provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "static_site" {
  bucket = "my-static-website-20250620"  # Must be globally unique
  acl    = "public-read"
}
