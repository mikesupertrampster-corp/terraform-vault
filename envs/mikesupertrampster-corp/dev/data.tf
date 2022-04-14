data "aws_vpc" "current" {
  tags = {
    Environment = var.environment
  }
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = "ECS"
}

data "aws_availability_zones" "current" {}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_availability_zones.current.names)

  vpc_id = data.aws_vpc.current.id
  tags = {
    Name = "${var.environment}-${var.subnet}-${each.key}"
  }
}