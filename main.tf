terraform {
  required_providers {
    aws = {
      source = "aws"
    }
  }
}

resource "random_pet" "petname" {
  length    = 3
  separator = "-"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "prod" {
  bucket = "${var.prod_prefix}-${random_pet.petname.id}"
  acl    = "public-read"

  policy = templatefile("${path.module}/policy.tftpl", {
    prefix = var.prod_prefix,
    pet-id = random_pet.petname.id
  })

  website {
    index_document = "index.html"

  }
  force_destroy = true
}

resource "aws_s3_bucket_object" "prod" {
  acl          = "public-read"
  key          = "index.html"
  bucket       = aws_s3_bucket.prod.id
  content      = file("${path.module}/assets/index.html")
  content_type = "text/html"

}
