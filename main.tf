provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "static_site" {
  bucket = "himchappidi"
  acl    = "public-read"
}
