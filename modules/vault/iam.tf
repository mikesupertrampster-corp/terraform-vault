resource "aws_iam_role" "vault" {
  name               = "${title(var.name)}Role"
  assume_role_policy = data.aws_iam_policy_document.ecs.json
}

resource "aws_iam_role_policy" "vault" {
  name   = aws_iam_role.vault.name
  policy = data.aws_iam_policy_document.vault.json
  role   = aws_iam_role.vault.id
}

resource "aws_iam_role" "execution" {
  name               = "${title(var.name)}EcsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs.json
}

data "aws_iam_policy" "execution" {
  for_each = toset(["AmazonECSTaskExecutionRolePolicy"])
  name     = each.key
}

resource "aws_iam_role_policy_attachment" "execution" {
  for_each   = data.aws_iam_policy.execution
  policy_arn = each.value.arn
  role       = aws_iam_role.execution.name
}
