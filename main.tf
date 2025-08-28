terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "aravind-terraform-state-bucket-ap-south-1"
    key    = "portfolio-frontend/terraform.tfstate"
    region = "ap-south-1"
  }
}

locals {
  mime_types = {
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "jpeg" = "image/jpeg",
    "jpg"  = "image/jpeg",
    "png"  = "image/png",
    "ico"  = "image/vnd.microsoft.icon",
    "txt"  = "text/plain"
  }
}

# tfsec:ignore:aws-s3-enable-bucket-logging
# tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = var.bucketname
}

# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "portfolio_bucket_encryption" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "portfolio_ownership_controls" {
  bucket = aws_s3_bucket.portfolio_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "portfolio_public_access_block" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "portfolio_files" {
  for_each = fileset("${path.module}/my-website-files/", "**")

  bucket       = aws_s3_bucket.portfolio_bucket.id
  key          = each.value
  source       = "${path.module}/my-website-files/${each.value}"
  content_type = lookup(local.mime_types, regex("\\.(\\w+)$", each.value)[0], "binary/octet-stream")
  etag         = filemd5("${path.module}/my-website-files/${each.value}")
}

resource "aws_cloudfront_origin_access_control" "portfolio_oac" {
  name                              = "OAC-${var.bucketname}"
  description                       = "OAC for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# tfsec:ignore:aws-cloudfront-enable-waf
# tfsec:ignore:aws-cloudfront-enable-logging
resource "aws_cloudfront_distribution" "portfolio_cdn" {
  origin {
    domain_name              = aws_s3_bucket.portfolio_bucket.bucket_regional_domain_name
    origin_id                = "S3-${var.bucketname}"
    origin_access_control_id = aws_cloudfront_origin_access_control.portfolio_oac.id
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = [var.domainname, "www.${var.domainname}"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.bucketname}"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_s3_bucket_policy" "portfolio_bucket_policy" {
  bucket = aws_s3_bucket.portfolio_bucket.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "cloudfront.amazonaws.com" },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.portfolio_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.portfolio_cdn.arn
          }
        }
      }
    ]
  })
}

resource "aws_acm_certificate" "portfolio_cert" {
  provider                  = aws.us_east_1
  domain_name               = var.domainname
  subject_alternative_names = ["www.${var.domainname}"]
  validation_method         = "DNS"
}

data "aws_route53_zone" "portfolio_zone" {
  name         = var.domainname
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  provider = aws.us_east_1
  for_each = {
    for dvo in aws_acm_certificate.portfolio_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.portfolio_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.portfolio_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "www_alias" {
  zone_id = data.aws_route53_zone.portfolio_zone.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root_alias" {
  zone_id = data.aws_route53_zone.portfolio_zone.zone_id
  name    = var.domainname
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}