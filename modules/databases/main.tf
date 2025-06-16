# Data source để lấy secrets từ AWS Secrets Manager
data "aws_secretsmanager_secret" "db_credentials" {
  name = "mapapp/${var.environment}/db-credentials"
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

# Parse JSON secrets
locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}

#-------------------------------------------------
# Security Group for all databases
#-------------------------------------------------
resource "aws_security_group" "db_sg" {
  name        = "mapapp-${var.environment}-db-sg"
  description = "Security group for all databases in the environment"
  vpc_id      = var.vpc_id

  # MySQL port
  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
  }

  # DocumentDB port
  ingress {
    description     = "DocumentDB from EKS nodes"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
  }

  # Redis port
  ingress {
    description     = "Redis from EKS nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "mapapp-${var.environment}-db-sg" })
}


#-------------------------------------------------
# RDS (MySQL)
#-------------------------------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "mapapp-${var.environment}-rds"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Name = "mapapp-${var.environment}-rds-subnet-group" })
}

resource "aws_db_instance" "mysql" {
  identifier           = "mapapp-${var.environment}-mysql"
  allocated_storage    = var.db_allocated_storage
  instance_class       = var.db_instance_class
  engine               = "mysql"
  engine_version       = "8.0"
  username             = local.db_creds.mysql_username
  password             = local.db_creds.mysql_password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az             = var.db_multi_az
  skip_final_snapshot  = true
  tags                 = merge(var.tags, { Name = "mapapp-${var.environment}-mysql" })
}


#-------------------------------------------------
# DocumentDB
#-------------------------------------------------
resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name       = "mapapp-${var.environment}-docdb"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Name = "mapapp-${var.environment}-docdb-subnet-group" })
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "mapapp-${var.environment}-docdb"
  engine                  = "docdb"
  master_username         = local.db_creds.docdb_username
  master_password         = local.db_creds.docdb_password
  db_subnet_group_name    = aws_docdb_subnet_group.docdb_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
  tags                    = merge(var.tags, { Name = "mapapp-${var.environment}-docdb" })
}

resource "aws_docdb_cluster_instance" "docdb_instances" {
  count              = var.docdb_instances
  identifier         = "mapapp-${var.environment}-docdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.docdb_instance_class
  tags               = merge(var.tags, { Name = "mapapp-${var.environment}-docdb-instance-${count.index}" })
}


#-------------------------------------------------
# ElastiCache (Redis)
#-------------------------------------------------
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "mapapp-${var.environment}-redis"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Name = "mapapp-${var.environment}-redis-subnet-group" })
}

# Create a standalone Redis cluster if no replicas are requested
resource "aws_elasticache_cluster" "redis_standalone" {
  count = var.redis_replicas == 0 ? 1 : 0

  cluster_id           = "mapapp-${var.environment}-redis"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.db_sg.id]
  tags                 = merge(var.tags, { Name = "mapapp-${var.environment}-redis" })
}

# Create a Redis replication group (HA) if replicas are requested
resource "aws_elasticache_replication_group" "redis_ha" {
  count = var.redis_replicas > 0 ? 1 : 0

  replication_group_id = "mapapp-${var.environment}-redis-ha"
  description          = "Redis HA cluster for mapapp"
  node_type            = var.redis_node_type
  num_cache_clusters   = var.redis_replicas + 1
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.db_sg.id]
  automatic_failover_enabled = true
  tags                 = merge(var.tags, { Name = "mapapp-${var.environment}-redis-ha" })
} 