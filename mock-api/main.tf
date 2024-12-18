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

resource "aws_ecs_task_definition" "api_task" {
  family = "mock-api-task"
  container_definitions = <<DEFINITION
  [
    {
        "name": "mock-api",
        "image": "docker.io/alikhakpouri/mock-api:1.0",
        "essential": true,
        "portMappings": [
            {
                "containerPort": 5000,
                "hostPort": 5000
            }
        ],
        "memory": 512,
        "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  memory = 512
  cpu = 256
  execution_role_arn = "${aws_iam_role.ecs_task_execution_role.arn}"
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ecs_task_execution_role"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
  
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
    role = "${aws_iam_role.ecs_task_execution_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  
}

resource "aws_default_vpc" "default_vpc" {
}

resource "aws_default_subnet" "mock_api_subnet_onea" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "mock_api_subnet_oneb" {
  availability_zone = "us-east-1b"
}

resource "aws_alb" "mock_api_load_balancer" {
  name = "load-balancer-mock-api"
  load_balancer_type = "application"

  subnets = [
    #referencing default subnets mentioned above
    "${aws_default_subnet.mock_api_subnet_onea.id}" ,
    "${aws_default_subnet.mock_api_subnet_oneb.id}" ,
    ]
    security_groups = [
        "${aws_security_group.load_balancer_security_group.id}"
    ]
}

resource "aws_security_group" "load_balancer_security_group" {
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] #this allows traffic from all resources
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb_target_group" "load_balancer_target_group" {
    name = "target-group"
    port = 80
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = "${aws_default_vpc.default_vpc.id}"
}

resource "aws_lb_listener" "listener" {
    load_balancer_arn = "${aws_alb.mock_api_load_balancer.arn}"
    port = "80"
    protocol = "HTTP"
    default_action {
      type = "forward"
      target_group_arn = "${aws_lb_target_group.load_balancer_target_group.arn}"
    }
}

##create ECS
resource "aws_ecs_service" "app_service" {
    name = "mock-api-service"
    cluster = "${aws_ecs_cluster.api_cluster.id}"
    task_definition = "${aws_ecs_task_definition.api_task.arn}"
    launch_type = "FARGATE"
    desired_count = 2
    
    load_balancer {
      target_group_arn = "${aws_lb_target_group.load_balancer_target_group.arn}"
      container_name = "${aws_ecs_task_definition.api_task.family}"
      container_port = 5000
    }

    network_configuration {
      subnets = [
        "${aws_default_subnet.mock_api_subnet_onea.id}",
        "${aws_default_subnet.mock_api_subnet_oneb.id}"
      ]
      assign_public_ip = true
      security_groups = [
        "${aws_security_group.load_balancer_security_group.id}"
      ]
    }   
}

resource "aws_security_group" "service_security_group" {
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = [
            "${aws_security_group.load_balancer_security_group.id}"
        ]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "app_url" {
  value = aws_alb.mock_api_load_balancer.dns_name
}