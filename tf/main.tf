terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.14.9"
}

### Providers ###
provider "aws" {
  profile = var.aws_profile
  region  = "eu-west-1"
}

provider "aws" {
  profile = var.aws_profile
  alias   = "usa"
  region  = "us-east-1"
}

provider "cloudflare" {
  email   = var.cloudflare_mail
  api_key = var.cloudflare_api_key
}

locals {
  s3_origin_id = "myS3Origin"
}

### S3 Bucket and Rights ###
resource "aws_cloudfront_origin_access_identity" "default" {
}

resource "aws_s3_bucket" "sitebucket" {
  bucket        = "statwebsite.norbitor.net.pl"
  acl           = "private"
  force_destroy = true
}

data "aws_iam_policy_document" "sitebucket_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.sitebucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "sitebucket_policy" {
  bucket = aws_s3_bucket.sitebucket.id
  policy = data.aws_iam_policy_document.sitebucket_policy_document.json
}

### Cloudfront ###
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.sitebucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["statwebsite.norbitor.net.pl"]

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

### SSL Certificate ###
resource "aws_acm_certificate" "cert" {
  provider          = aws.usa
  domain_name       = "statwebsite.norbitor.net.pl"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "validation" {
  zone_id = "186a1749b8c8059060b22d270497b937"

  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name  = each.value.name
  value = each.value.record
  type  = each.value.type
  ttl   = 300
}

### Cloudflare ###
resource "cloudflare_record" "cfalias" {
  zone_id = var.cloudflare_zone_id
  name    = "statwebsite"
  value   = aws_cloudfront_distribution.s3_distribution.domain_name
  type    = "CNAME"
}

