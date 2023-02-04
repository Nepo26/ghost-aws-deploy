
#Key Information
resource "aws_kms_key" "terraform-bucket-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key-alias" {
  name          = "alias/terraform-bucket-key"
  target_key_id = aws_kms_key.terraform-bucket-key.id
}



#Policy Document
data "aws_iam_policy_document" "kms" {
  statement {
    sid = "AllowUseOfTheTerraformKey"

    # https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [aws_kms_key.terraform-bucket-key.arn]
  }
}


resource "aws_iam_policy" "kms" {
  name        = "kms-terraform-key-policy"
  path        = "/"
  description = ""
  policy      = data.aws_iam_policy_document.kms.json
}


# S3 Bucket Specific Info
resource "aws_s3_bucket" "terraform-state" {
  bucket = "${var.application_name}-terraform"

}

#ACL isn't destroyed after delete
resource "aws_s3_bucket_acl" "terraform-state-bucket-acl" {
  bucket = aws_s3_bucket.terraform-state.id
  acl = "private"

}

resource "aws_s3_bucket_versioning" "terraform-state-bucket-versioning" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-state-bucket-sse" {
  bucket = aws_s3_bucket.terraform-state.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
      sse_algorithm     = "aws:kms"
    }
  }

}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


#Dynamo Info
resource "aws_dynamodb_table" "terraform-state" {
  name = "${var.application_name}-terraform-state-lock"
  read_capacity = 20
  write_capacity = 20
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}