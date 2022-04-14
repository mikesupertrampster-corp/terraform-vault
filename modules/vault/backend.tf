resource "aws_dynamodb_table" "vault" {
  name         = var.name
  hash_key     = "Path"
  range_key    = "Key"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  point_in_time_recovery { enabled = false }
}

resource "aws_kms_key" "vault" {
  description             = var.name
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "vault" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.vault.id
}

resource "aws_cloudwatch_log_group" "vault" {
  name              = "/ecs/${var.name}"
  retention_in_days = 7
}