data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_route53_zone" "current" {
  name = "${var.environment}.${var.apex_domain}"
}

data "aws_security_group" "alb" {
  name = "alb"
}

data "aws_lb" "alb" {
  name = var.environment
}

data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.alb.arn
  port              = 443
}

data "aws_iam_policy_document" "ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "kms" {
  statement {
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }

  statement {
    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.vault.arn,
      ]
    }
  }
}

data "aws_iam_policy_document" "vault" {
  statement {
    actions = [
      "ec2:*",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole",
      "sts:*",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:GetChange",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
    ]
    resources = [
      aws_kms_key.vault.arn,
      aws_kms_alias.vault.arn,
    ]
  }

  statement {
    actions = [
      "kms:Get*",
      "kms:ListKeys",
      "kms:ListAliases",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "iam:AttachUserPolicy",
      "iam:CreateAccessKey",
      "iam:CreateUser",
      "iam:DeleteAccessKey",
      "iam:DeleteUser",
      "iam:DeleteUserPolicy",
      "iam:DetachUserPolicy",
      "iam:ListAccessKeys",
      "iam:ListAttachedUserPolicies",
      "iam:ListGroupsForUser",
      "iam:ListUserPolicies",
      "iam:PutUserPolicy",
      "iam:RemoveUserFromGroup",
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vault-*"]
  }

  statement {
    actions = [
      "dynamodb:ListTables",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "kms:List*",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListTables",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable",
    ]
    resources = [aws_dynamodb_table.vault.arn]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:*:*:*"]
  }
}
