output "website_bucket" {
  value = aws_s3_bucket.website_bucket.bucket
}

output "cdn_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "logs_bucket" {
  value = aws_s3_bucket.logs_bucket.bucket
}
