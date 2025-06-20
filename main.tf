resource "aws_s3_bucket" "website_bucket" {
  bucket = "today-201-1-203-12" # Replace with your desired bucket name
  acl    = "private" # Keep the ACL private, we'll use a bucket policy for public access

  website {
    index_document = "index.html"
    error_document = "error.html" # Optional error document
  }
}

resource "aws_s3_bucket_public_access_block" "prevent_public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "PublicReadGetObject",
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}
