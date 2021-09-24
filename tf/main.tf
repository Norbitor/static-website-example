terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

resource "aws_s3_bucket" "sitebucket" {
  bucket = "statwebtest.norbitor.net.pl"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error/index.html"
  }
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.sitebucket.id
  policy = jsonencode({ Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.sitebucket.arn,
          "${aws_s3_bucket.sitebucket.arn}/*",
        ]
      },
    ]
    }
  )
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.sitebucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

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

  //aliases = ["statwebsite.norbitor.net.pl"]

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
