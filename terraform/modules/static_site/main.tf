#####################################
# S3 Website Bucket
#####################################
resource "aws_s3_bucket" "website_bucket" {
  bucket = "fsl-${var.env}-website-bucket"

  tags = {
    Name        = "website-${var.env}"
    Environment = var.env
  }
}

# Static website configuration
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

#####################################
# S3 Logs Bucket
#####################################
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "fsl-${var.env}-logs-bucket"

  tags = {
    Name        = "logs-${var.env}"
    Environment = var.env
  }
}

resource "aws_s3_bucket_ownership_controls" "logs_bucket_ownership" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "logs_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.logs_bucket_ownership]
  bucket     = aws_s3_bucket.logs_bucket.id
  acl        = "log-delivery-write"
}

#####################################
# CloudFront Distribution
#####################################
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website_bucket.id}"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.website_bucket.id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    # ✅ Added - Required field
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Logging (optional)
  logging_config {
    bucket          = aws_s3_bucket.logs_bucket.bucket_domain_name
    include_cookies = false
  }

  tags = {
    Name        = "cdn-${var.env}"
    Environment = var.env
  }
}
