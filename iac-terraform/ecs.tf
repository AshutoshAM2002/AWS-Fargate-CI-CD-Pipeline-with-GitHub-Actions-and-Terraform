resource "aws_ecs_task_definition" "express_app" {
  family                   = "express-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = <<DEFINITION
[
  {
    "image": "public.ecr.aws/e7u6v3p1/pearl-through:latest",
    "cpu": 1024,
    "memory": 2048,
    "name": "express-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_cluster" "express_app_cluster" {
  name = "express-app-cluster"
}

resource "aws_ecs_service" "express_app_service" {
  name            = "express-app-service"
  cluster         = aws_ecs_cluster.express_app_cluster.id
  task_definition = aws_ecs_task_definition.express_app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.express_app_sg.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.id
    container_name   = "express-app"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.listener]
}