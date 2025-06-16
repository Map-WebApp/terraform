module "vpc" {
  source = "../../modules/vpc"

  vpc_name             = "mapapp-dev-vpc"
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  tags                 = var.tags
}

module "keypair" {
  source = "../../modules/keypair"

  key_name        = var.key_name
  public_key_path = var.public_key_path
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 3
      desired_size   = 2
      key_name       = module.keypair.key_name
    }
  }

  tags = var.tags
}

module "iam_jenkins" {
  source = "../../modules/iam"

  role_name                 = "mapapp-dev-jenkins-role"
  oidc_provider_arn         = module.eks.oidc_provider_arn
  oidc_provider_url         = module.eks.oidc_provider_url
  service_account_namespace = "cicd"
  service_account_name      = "jenkins"
  attach_policy_arns        = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]
  tags                      = var.tags
}

resource "aws_security_group" "db_sg" {
  name        = "mapapp-dev-db-sg"
  description = "Allow EKS nodes to access all databases"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306 // MySQL
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  ingress {
    from_port       = 27017 // DocumentDB
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  ingress {
    from_port       = 6379 // Redis
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_db_subnet_group" "rds" {
  name       = "mapapp-dev-rds-sng"
  subnet_ids = module.vpc.private_subnets_ids
  tags       = var.tags
}

resource "aws_db_instance" "mysql" {
  identifier           = "mapapp-dev-mysql"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_subnet_group_name = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  tags                 = var.tags
}

resource "aws_docdb_subnet_group" "docdb" {
  name       = "mapapp-dev-docdb-sng"
  subnet_ids = module.vpc.private_subnets_ids
  tags       = var.tags
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "mapapp-dev-docdb"
  engine_version          = "4.0.0"
  master_username         = var.docdb_username
  master_password         = var.docdb_password
  db_subnet_group_name    = aws_docdb_subnet_group.docdb.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
  tags                    = var.tags
}

resource "aws_docdb_cluster_instance" "docdb" {
  count              = 1
  identifier         = "mapapp-dev-docdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
  tags               = var.tags
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "mapapp-dev-redis-sng"
  subnet_ids = module.vpc.private_subnets_ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "mapapp-dev-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.db_sg.id]
  tags                 = var.tags
}

module "efs" {
  source = "../../modules/efs"

  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids
  node_sg_id  = module.eks.node_security_group_id
  efs_name    = var.efs_name
  tags        = var.tags
}
