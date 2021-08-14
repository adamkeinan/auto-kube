# Create S3 Bucket per environment with for_each and maps
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

resource "aws_s3_bucket" "eks3bucket" {

  # for_each Meta-Argument
  for_each = {
    dev     = "eks_s3-dev-bucket"
    qa      = "eks_s3-qa-bucket"
    stag    = "eks_s3-stag-bucket"
    prod    = "eks_s3-prod-bucket"
    backend = "eks_s3-backend"
  }

  bucket = "${each.key}-${each.value}"
  acl    = "private"

  tags = {
    Environment = each.key
    bucketname  = "${each.key}-${each.value}"
    eachvalue   = each.value
  }
}