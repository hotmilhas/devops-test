provider "aws" {}

# VPC
resource "aws_vpc" "devops-test-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags {
    Name = "devops-test-vpc"
  }
}

# Subnets
resource "aws_subnet" "devops-test-subnet-a" {
  vpc_id                  = "${aws_vpc.devops-test-vpc.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags {
    Name = "devops-test-subnet-a"
  }
}

resource "aws_subnet" "devops-test-subnet-b" {
  vpc_id                  = "${aws_vpc.devops-test-vpc.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags {
    Name = "devops-test-subnet-b"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "devops-test-db-subnet" {
  name       = "devops-test-db-subnet"
  subnet_ids = ["${aws_subnet.devops-test-subnet-a.id}", "${aws_subnet.devops-test-subnet-b.id}"]

  tags {
    Name = "devops-test-db-subnet"
  }
}

# RDS Security Group
resource "aws_security_group" "devops-test-mysql-security-group" {
  name        = "devops-test-mysql-security-group"
  description = "devops-test-mysql-security-group"
  vpc_id      = "${aws_vpc.devops-test-vpc.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "devops-test-mysql-security-group"
  }
}

# ECS and Load Balance Security Group
resource "aws_security_group" "devops-test-ecs-php-security-group" {
  name        = "devops-test-ecs-php-security-group"
  description = "devops-test-ecs-php-security-group"
  vpc_id      = "${aws_vpc.devops-test-vpc.id}"

  ingress {
    from_port   = 4444
    to_port     = 4444
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "devops-test-ecs-php-security-group"
  }
}

resource "aws_security_group" "devops-test-ecs-node-security-group" {
  name        = "devops-test-ecs-node-security-group"
  description = "devops-test-ecs-node-security-group"
  vpc_id      = "${aws_vpc.devops-test-vpc.id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "devops-test-ecs-node-security-group"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "devops-test-internet-gateway" {
  vpc_id = "${aws_vpc.devops-test-vpc.id}"

  tags {
    Name = "devops-test-internet-gateway"
  }
}

# Route Table
resource "aws_route_table" "devops-test-route-table" {
  vpc_id = "${aws_vpc.devops-test-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.devops-test-internet-gateway.id}"
  }

  tags {
    Name = "devops-test-route-table"
  }
}

resource "aws_main_route_table_association" "devops-test-route-table-association" {
  vpc_id         = "${aws_vpc.devops-test-vpc.id}"
  route_table_id = "${aws_route_table.devops-test-route-table.id}"
}


# RDS Instance (MYSQL)
resource "aws_db_instance" "devops-test-mysql" {
  depends_on = ["aws_internet_gateway.devops-test-internet-gateway"]
  allocated_storage         = 10                                                            # 10 GB of storage
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t2.micro"                                                 # use micro if you want to use the free tier
  identifier                = "devops-test-mysql"
  name                      = "devops_test"                                                 # database name
  username                  = "root"                                                        # username
  password                  = "${var.MYSQL_PASSWORD}"                                       # password
  multi_az                  = "false"
  storage_type              = "gp2"
  availability_zone         = "us-east-1a"                                                  # prefered AZ
  db_subnet_group_name      = "${aws_db_subnet_group.devops-test-db-subnet.name}"
  final_snapshot_identifier = "devops-test-mysql"                                           # final snapshot when executing terraform destroy
  skip_final_snapshot       = "true"
  publicly_accessible       = "true"
  vpc_security_group_ids    = ["${aws_security_group.devops-test-mysql-security-group.id}"]

  tags {
    Name = "devops-test-mysql"
  }
}

# ECS IAM
resource "aws_iam_role" "devops-test-ecs-execution-role" {
  name               = "devops-test-ecs-task-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "devops-test-ecs-execution-role-policy" {
  name   = "devops-test-ecs-execution-role-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
  role   = "${aws_iam_role.devops-test-ecs-execution-role.id}"
}

resource "aws_iam_role" "devops-test-ecs-role" {
  name               = "devops-test-ecs-role"
  assume_role_policy = "${data.aws_iam_policy_document.devops-test-ecs-service-role.json}"
}

resource "aws_iam_role_policy" "devops-test-ecs-service-role-policy" {
  name   = "devopst-test-ecs-service-role-policy"
  policy = "${data.aws_iam_policy_document.devops-test-ecs-service-policy.json}"
  role   = "${aws_iam_role.devops-test-ecs-role.id}"
}

data "aws_iam_policy_document" "devops-test-ecs-service-policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "ec2:Describe*",
      "ec2:AuthorizeSecurityGroupIngress",
    ]
  }
}

data "aws_iam_policy_document" "devops-test-ecs-service-role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "devops-test-ecs-cluster" {
  name = "devops-test-ecs-cluster"
}

# ECR Repository
resource "aws_ecr_repository" "devops-php-test-ecr" {
  name = "devops-php-test-ecr"
}

resource "aws_ecr_repository" "devops-node-test-ecr" {
  name = "devops-node-test-ecr"
}

# ECS Task Definition
data "template_file" "devops-php-test-template" {
  template = "${file("container-conf.json")}"

  vars {
    image               = "${aws_ecr_repository.devops-php-test-ecr.repository_url}"
    container_name      = "devops-php-test"
    container_port      = 4444
    desired_task_cpu    = 256
    desired_task_memory = 512
  }
}

data "template_file" "devops-node-test-template" {
  template = "${file("container-conf.json")}"

  vars {
    image               = "${aws_ecr_repository.devops-node-test-ecr.repository_url}"
    container_name      = "devops-node-test"
    container_port      = 8080
    desired_task_cpu    = 256
    desired_task_memory = 512
  }
}

resource "aws_ecs_task_definition" "devops-php-test-task" {
  family                   = "devops-php-test-task"
  container_definitions    = "${data.template_file.devops-php-test-template.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = "${aws_iam_role.devops-test-ecs-execution-role.arn}"
  task_role_arn      = "${aws_iam_role.devops-test-ecs-execution-role.arn}"
}

resource "aws_ecs_task_definition" "devops-node-test-task" {
  family                   = "devops-node-test-task"
  container_definitions    = "${data.template_file.devops-node-test-template.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = "${aws_iam_role.devops-test-ecs-execution-role.arn}"
  task_role_arn      = "${aws_iam_role.devops-test-ecs-execution-role.arn}"
}

# ECR Load Balancer

resource "aws_alb_target_group" "devops-php-test-alb-target-group" {
  name     = "devops-php-test-alb-tg"
  port     = 4444
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.devops-test-vpc.id}"
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_target_group" "devops-node-test-alb-target-group" {
  name     = "devops-node-test-alb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.devops-test-vpc.id}"
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb" "devops-php-test-alb-openjobs" {
  name            = "devops-php-test-alb-openjobs"
  subnets         = ["${aws_subnet.devops-test-subnet-a.id}", "${aws_subnet.devops-test-subnet-b.id}"]
  security_groups = ["${aws_security_group.devops-test-ecs-php-security-group.id}"]

  tags {
    Name        = "devops-php-test-alb-openjobs"
    Environment = "devops-php-test"
  }
}

resource "aws_alb" "devops-node-test-alb-openjobs" {
  name            = "devops-node-test-alb-openjobs"
  subnets         = ["${aws_subnet.devops-test-subnet-a.id}", "${aws_subnet.devops-test-subnet-b.id}"]
  security_groups = ["${aws_security_group.devops-test-ecs-node-security-group.id}"]

  tags {
    Name        = "devops-node-test-alb-openjobs"
    Environment = "devops-node-test"
  }
}

resource "aws_alb_listener" "devops-php-test-openjobs" {
  load_balancer_arn = "${aws_alb.devops-php-test-alb-openjobs.arn}"
  port              = "4444"
  protocol          = "HTTP"
  depends_on        = ["aws_alb_target_group.devops-php-test-alb-target-group"]

  default_action {
    target_group_arn = "${aws_alb_target_group.devops-php-test-alb-target-group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "devops-node-test-openjobs" {
  load_balancer_arn = "${aws_alb.devops-node-test-alb-openjobs.arn}"
  port              = "8080"
  protocol          = "HTTP"
  depends_on        = ["aws_alb_target_group.devops-node-test-alb-target-group"]

  default_action {
    target_group_arn = "${aws_alb_target_group.devops-node-test-alb-target-group.arn}"
    type             = "forward"
  }
}

# ECS Service
resource "aws_ecs_service" "devops-php-test" {
  name            = "devops-php-test"
  task_definition = "${aws_ecs_task_definition.devops-php-test-task.arn}"
  cluster         = "${aws_ecs_cluster.devops-test-ecs-cluster.id}"
  launch_type     = "FARGATE"
  desired_count   = "1"

  network_configuration {
    subnets          = ["${aws_subnet.devops-test-subnet-a.id}"]
    security_groups  = ["${aws_security_group.devops-test-ecs-php-security-group.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.devops-php-test-alb-target-group.arn}"
    container_name   = "devops-php-test"
    container_port   = "4444"
  }

  depends_on = ["aws_iam_role_policy.devops-test-ecs-service-role-policy", "aws_alb_listener.devops-php-test-openjobs"]
}

resource "aws_ecs_service" "devops-node-test" {
  name            = "devops-node-test"
  task_definition = "${aws_ecs_task_definition.devops-node-test-task.arn}"
  cluster         = "${aws_ecs_cluster.devops-test-ecs-cluster.id}"
  launch_type     = "FARGATE"
  desired_count   = "1"

  network_configuration {
    subnets          = ["${aws_subnet.devops-test-subnet-a.id}"]
    security_groups  = ["${aws_security_group.devops-test-ecs-node-security-group.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.devops-node-test-alb-target-group.arn}"
    container_name   = "devops-node-test"
    container_port   = "8080"
  }

  depends_on = ["aws_iam_role_policy.devops-test-ecs-service-role-policy", "aws_alb_listener.devops-node-test-openjobs"]
}

# CodePipeline S3 Bucket
resource "aws_s3_bucket" "devops-php-test-pipeline" {
  bucket        = "devops-php-test-pipeline"
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "devops-node-test-pipeline" {
  bucket        = "devops-node-test-pipeline"
  acl           = "private"
  force_destroy = true
}

# CodePipeline IAM
resource "aws_iam_role" "devops-test-codepipeline-role" {
  name               = "devops-test-codepipeline-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "template_file" "devops-php-test-codepipeline-policy" {
  template = "${file("codepipeline_policy.json")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.devops-php-test-pipeline.arn}"
  }
}

data "template_file" "devops-node-test-codepipeline-policy" {
  template = "${file("codepipeline_policy.json")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.devops-node-test-pipeline.arn}"
  }
}

resource "aws_iam_role_policy" "devops-php-test-codepipeline-policy" {
  name   = "devops-php-test-codepipeline-policy"
  role   = "${aws_iam_role.devops-test-codepipeline-role.id}"
  policy = "${data.template_file.devops-php-test-codepipeline-policy.rendered}"
}

resource "aws_iam_role_policy" "devops-node-test-codepipeline-policy" {
  name   = "devops-node-test-codepipeline-policy"
  role   = "${aws_iam_role.devops-test-codepipeline-role.id}"
  policy = "${data.template_file.devops-node-test-codepipeline-policy.rendered}"
}

resource "aws_iam_role" "devops-test-codebuild-role" {
  name               = "devops-test-codebuild-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "template_file" "devops-php-test-codebuild-policy" {
  template = "${file("codebuild_policy.json")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.devops-php-test-pipeline.arn}"
  }
}

data "template_file" "devops-node-test-codebuild-policy" {
  template = "${file("codebuild_policy.json")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.devops-node-test-pipeline.arn}"
  }
}

resource "aws_iam_role_policy" "devops-php-test-codebuild-policy" {
  name   = "devops-php-test-codebuild-policy"
  role   = "${aws_iam_role.devops-test-codebuild-role.id}"
  policy = "${data.template_file.devops-php-test-codebuild-policy.rendered}"
}

resource "aws_iam_role_policy" "devops-node-test-codebuild-policy" {
  name   = "devops-node-test-codebuild-policy"
  role   = "${aws_iam_role.devops-test-codebuild-role.id}"
  policy = "${data.template_file.devops-node-test-codebuild-policy.rendered}"
}

# CodePipeline PHP Project
resource "aws_codepipeline" "devops-php-test-pipeline" {
  depends_on = ["aws_iam_role_policy.devops-php-test-codebuild-policy"]
  name     = "devops-php-test-pipeline"
  role_arn = "${aws_iam_role.devops-test-codepipeline-role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.devops-php-test-pipeline.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner  = "${var.GITHUB_USER}"
        Repo   = "devops-php-test"
        Branch = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "devops-php-test-codebuild"
      }
    }
  }

  stage {
    name = "Production"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration {
        ClusterName = "devops-test-ecs-cluster"
        ServiceName = "devops-php-test"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

data "template_file" "devops-php-test-buildspec" {
  template = "${file("codepipeline-buildspec/buildspec-devops-php-test.yml")}"

  vars {
    repository_url = "${aws_ecr_repository.devops-php-test-ecr.repository_url}"
    region         = "us-east-1"
    cluster_name   = "devops-test-ecs-cluster"
    container_name = "devops-php-test"

    security_group_ids = "${aws_security_group.devops-test-mysql-security-group.id}"
  }
}

resource "aws_codebuild_project" "devops-php-test-app-build" {
  name          = "devops-php-test-codebuild"
  build_timeout = "60"

  service_role = "${aws_iam_role.devops-test-codebuild-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"

    // https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      "name"  = "APP_ENV"
      "value" = "production"
    }

    environment_variable {
      "name"  = "DB_HOST"
      "value" = "${aws_db_instance.devops-test-mysql.address}"
    }

    environment_variable {
      "name"  = "DB_PORT"
      "value" = "${aws_db_instance.devops-test-mysql.port}"
    }

    environment_variable {
      "name"  = "DB_DATABASE"
      "value" = "${aws_db_instance.devops-test-mysql.name}"
    }

    environment_variable {
      "name"  = "DB_USER"
      "value" = "${aws_db_instance.devops-test-mysql.username}"
    }

    environment_variable {
      "name"  = "DB_PASSWORD"
      "value" = "${aws_db_instance.devops-test-mysql.password}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.devops-php-test-buildspec.rendered}"
  }
}

# CodePipeline Node Project
resource "aws_codepipeline" "devops-node-test-pipeline" {
  depends_on = ["aws_iam_role_policy.devops-node-test-codebuild-policy"]
  name     = "devops-node-test-pipeline"
  role_arn = "${aws_iam_role.devops-test-codepipeline-role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.devops-node-test-pipeline.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner  = "${var.GITHUB_USER}"
        Repo   = "devops-node-test"
        Branch = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "devops-node-test-codebuild"
      }
    }
  }

  stage {
    name = "Production"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration {
        ClusterName = "devops-test-ecs-cluster"
        ServiceName = "devops-node-test"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

data "template_file" "devops-node-test-buildspec" {
  template = "${file("codepipeline-buildspec/buildspec-devops-node-test.yml")}"

  vars {
    repository_url = "${aws_ecr_repository.devops-node-test-ecr.repository_url}"
    region         = "us-east-1"
    cluster_name   = "devops-test-ecs-cluster"
    container_name = "devops-node-test"

    security_group_ids = "${aws_security_group.devops-test-mysql-security-group.id}"
  }
}

resource "aws_codebuild_project" "devops-node-test-app-build" {
  name          = "devops-node-test-codebuild"
  build_timeout = "60"

  service_role = "${aws_iam_role.devops-test-codebuild-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"

    // https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      "name"  = "APP_ENV"
      "value" = "production"
    }

    environment_variable {
      "name"  = "APP_PORT"
      "value" = "8080"
    }

    environment_variable {
      "name"  = "APP_HOSTNAME"
      "value" = "http://localhost"
    }

    environment_variable {
      "name"  = "PHP_HOSTNAME"
      "value" = "http://${aws_alb.devops-php-test-alb-openjobs.dns_name}"
    }

    environment_variable {
      "name"  = "PHP_PORT"
      "value" = "4444"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.devops-node-test-buildspec.rendered}"
  }
}