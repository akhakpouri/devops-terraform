terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_ecs_cluster" "api_cluster" {
  name = "mock-api-cluster"
}

# resource "aws_ecs_task_definition" "api_task" {
#   family = "mock-api-task"
#   container_definitions = <<DEFINITION
#   [
#     {
#         "name": "mock-api",
#         "image": "docker.io/alikhakpouri/mock-api:1.0",
#         "essential": true,
#         "portMappings": [
#             {
#                 "containerPort": 5000,
#                 "hostPort": 5000
#             }
#         ],
#         "memory": 512,
#         "cpu": 256
#     }
#   ]
#   DEFINITION
#   requires_compatibilities = ["FARGATE"]
#   network_mode = "awsvpc"
#   memory = 512
#   cpu = 256
#   execution_role_arn = "${aws_iam_role.ecs_task_execution_role}"
# }

# resource "aws_iam_role" "ecs_task_execution_role" {
#     name = "ecs_task_execution_role"
#     assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy}"
  
# }

# data "aws_iam_policy_document" "assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }