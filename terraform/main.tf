# Local variables to hold common configuration items
locals {
  cluster_name = "bluebirdhotel"

  vpc_name = "${local.cluster_name}-vpc"
  region   = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
}

# Data source to get a list of available AWS availability zones
data "aws_availability_zones" "available" {}

# Module to create a VPC with public, private, and database subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = local.vpc_name
  cidr = local.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]

  create_database_subnet_group = true

  enable_nat_gateway = true
  single_nat_gateway = true

  create_igw       = true
  instance_tenancy = "default"
}

# Module to create an EKS cluster with configuration for node groups and cluster access
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.9.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.k8s_version

  vpc_id                                   = module.vpc.vpc_id
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  control_plane_subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  eks_managed_node_groups = var.workers_config
}

# Resource for creating an AWS ECR repository for Docker images
resource "aws_ecr_repository" "app" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

# Module to create an RDS instance with configurations for MySQL engine
module "db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "6.6.0"
  identifier = "rds"

  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = var.db_name
  username = var.rds_master_user
  password = var.rds_password
  port     = 3306

  manage_master_user_password = false
  storage_encrypted           = false

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.mysql_security_group.security_group_id]

  skip_final_snapshot = true
  deletion_protection = false
  depends_on          = [module.mysql_security_group]
}

# Module to create a security group for MySQL, allowing access from within the VPC
module "mysql_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "mysql-sec-grp"
  description = "Hotel Management App deployment MySQL security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
}

# Module to deploy the NGINX Ingress Controller using Helm, configuring annotations for AWS NLB
module "nginx-controller" {
  source     = "terraform-iaac/nginx-controller/helm"
  version    = "2.3.0"
  depends_on = [module.eks]
  additional_set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
      value = "true"
      type  = "string"
    }
  ]
}


