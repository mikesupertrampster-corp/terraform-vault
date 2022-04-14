resource "aws_ecs_task_definition" "vault" {
  family                   = var.name
  execution_role_arn       = aws_iam_role.execution.arn
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.vault.arn

  runtime_platform {
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name       = "vault"
      image      = var.vault_image
      cpu        = 0
      essential  = true
      privileged = false
      command    = ["vault", "server", "-log-format=json", "-config=/vault/config/local.json"]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.vault.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }

      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
          protocol      = "tcp"
        },
        {
          containerPort = var.port + 1
          hostPort      = var.port + 1
          protocol      = "tcp"
        },
        {
          containerPort = var.port + 50
          hostPort      = var.port + 50
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command  = ["CMD-SHELL", "wget -O- -q localhost:${var.port}/v1/sys/health?standbyok=true&uninitcode=200"]
        interval = 30
        timeout  = 5
        retries  = 3
      }

      environment = [
        {
          name  = "VAULT_ADDR",
          value = "http://0.0.0.0:${var.port}",
        },
        {
          name  = "VAULT_API_ADDR",
          value = "http://0.0.0.0:${var.port}",
        },
        {
          name  = "VAULT_CLUSTER_ADDR",
          value = "http://0.0.0.0:${var.port + 1}",
        },
        {
          name  = "AWS_DEFAULT_REGION",
          value = data.aws_region.current.name,
        },
        {
          name  = "DYNAMODB_HA_ENABLED",
          value = "true",
        },
        {
          name  = "AWS_DYNAMODB_TABLE",
          value = aws_dynamodb_table.vault.name,
        },
        {
          name  = "VAULT_SEAL_TYPE",
          value = "awskms"
        },
        {
          name  = "VAULT_AWSKMS_SEAL_KEY_ID",
          value = aws_kms_alias.vault.target_key_arn,
        },
        {
          name = "VAULT_LOCAL_CONFIG"
          value = jsonencode({
            kvVersion = 2

            listener = [{
              tcp = {
                tls_disable     = "true"
                address         = "0.0.0.0:${var.port}"
                cluster_address = "0.0.0.0:${var.port + 1}"
              }
            }]
            backend = {
              dynamodb = {}
            }
            default_lease_ttl = "168h"
            max_lease_ttl     = "720h"
            ui                = true
          })
        },
      ]
    }
  ])
}

resource "aws_security_group" "vault" {
  name   = var.name
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.vault.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
}

resource "aws_security_group_rule" "ingress" {
  security_group_id        = aws_security_group.vault.id
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.alb.id
  type                     = "ingress"
}

resource "aws_ecs_service" "vault" {
  name                    = var.name
  cluster                 = var.cluster_arn
  task_definition         = aws_ecs_task_definition.vault.arn
  desired_count           = var.desired_count
  enable_ecs_managed_tags = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 1
  }

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.vault.id]
    subnets          = var.subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.vault.arn
    container_name   = "vault"
    container_port   = var.port
  }
}