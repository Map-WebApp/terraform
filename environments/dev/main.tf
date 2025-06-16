# Configure Terraform backend
terraform {
  backend "s3" {
    bucket         = "mapapp-terraform-state-storage"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "mapapp-terraform-state-lock"
    encrypt        = true
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# Local values
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Owner       = "DevOps"
  }
  
  cluster_name = "${var.project_name}-${var.environment}-eks"
  vpc_name     = "${var.project_name}-${var.environment}-vpc"
}

#---------------------------------------------------------
# VPC Module
#---------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  vpc_name               = local.vpc_name
  cidr_block            = var.vpc_cidr
  azs                   = var.azs
  private_subnet_cidrs  = var.private_subnet_cidrs
  public_subnet_cidrs   = var.public_subnet_cidrs
  enable_nat_gateway    = true
  single_nat_gateway    = var.single_nat_gateway

  tags = local.common_tags
}

#---------------------------------------------------------
# Key Pair Module
#---------------------------------------------------------
module "keypair" {
  source = "../../modules/keypair"

  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = var.public_key
}

#---------------------------------------------------------
# EKS Module
#---------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  cluster_name           = local.cluster_name
  cluster_version        = var.cluster_version
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  node_instance_type    = var.eks_instance_type
  node_desired_capacity = var.eks_desired_nodes
  key_name              = module.keypair.key_name

  tags = local.common_tags
}

#---------------------------------------------------------
# IAM Module
#---------------------------------------------------------
module "iam" {
  source = "../../modules/iam"

  cluster_oidc_issuer_url = module.eks.oidc_provider_url
  cluster_name           = local.cluster_name

  tags = local.common_tags
}

#---------------------------------------------------------
# Databases Module
#---------------------------------------------------------
module "databases" {
  source = "../../modules/databases"

  environment         = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  node_security_group_id = module.eks.node_security_group_id

  # RDS MySQL Configuration
  db_instance_class = var.db_instance_class
  db_multi_az       = var.db_multi_az

  # DocumentDB Configuration
  docdb_instance_class = var.docdb_instance_class
  docdb_instances     = var.docdb_instances

  # Redis Configuration
  redis_node_type = var.redis_node_type
  redis_replicas  = var.redis_replicas

  tags = local.common_tags
}

#---------------------------------------------------------
# EFS Module
#---------------------------------------------------------
module "efs" {
  source = "../../modules/efs"

  efs_name               = "${var.project_name}-${var.environment}-efs"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  node_security_group_id = module.eks.node_security_group_id

  tags = local.common_tags
}

#---------------------------------------------------------
# Helm Releases Module - Only for DEV environment
#---------------------------------------------------------
module "helm_releases" {
  source = "../../modules/helm-releases"

  cluster_name         = local.cluster_name
  cluster_endpoint     = module.eks.cluster_endpoint
  aws_region          = var.region

  # Enable components for DEV environment
  enable_aws_load_balancer_controller = true
  enable_efs_csi_driver              = true
  enable_jenkins                     = true
  enable_argocd                      = true
  enable_cluster_autoscaler          = true

  # IAM Role ARNs
  aws_load_balancer_controller_role_arn = module.iam.aws_load_balancer_controller_role_arn
  efs_csi_driver_role_arn              = module.iam.efs_csi_driver_role_arn
  jenkins_role_arn                     = module.iam.jenkins_role_arn
  cluster_autoscaler_role_arn          = module.iam.cluster_autoscaler_role_arn

  depends_on = [module.eks, module.iam, module.efs]
}
