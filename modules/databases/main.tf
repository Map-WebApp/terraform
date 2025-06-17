# Data source để lấy secrets từ AWS Secrets Manager
data "aws_secretsmanager_secret" "db_credentials" {
  name = "mapapp/${var.environment}/db-credentials"
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = "mapapp/${var.environment}/db-credentials"
}

# Parse JSON secrets
locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
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
resource "aws_db_subnet_group" "rds" {
  name       = "mapapp-${var.environment}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "rds_sg" {
  name        = "mapapp-${var.environment}-rds-sg"
  description = "Allow traffic to RDS from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [var.node_security_group_id]
  }

  tags = var.tags
}

resource "aws_db_instance" "mysql" {
  identifier           = "mapapp-${var.environment}-mysql"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_class
  username             = local.db_credentials.mysql_username
  password             = local.db_credentials.mysql_password
  db_subnet_group_name = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
  multi_az             = var.db_multi_az
  tags                 = var.tags
}


#-------------------------------------------------
# DocumentDB
#-------------------------------------------------
resource "aws_docdb_subnet_group" "docdb" {
  name       = "mapapp-${var.environment}-docdb-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "docdb_sg" {
  name        = "mapapp-${var.environment}-docdb-sg"
  description = "Allow traffic to DocumentDB from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 27017
    to_port         = 27017
    security_groups = [var.node_security_group_id]
  }

  tags = var.tags
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "mapapp-${var.environment}-docdb"
  engine                  = "docdb"
  master_username         = local.db_credentials.docdb_username
  master_password         = local.db_credentials.docdb_password
  db_subnet_group_name    = aws_docdb_subnet_group.docdb.name
  vpc_security_group_ids  = [aws_security_group.docdb_sg.id]
  skip_final_snapshot     = true
  tags                    = var.tags
}

resource "aws_docdb_cluster_instance" "docdb" {
  count              = var.docdb_instances
  identifier         = "mapapp-${var.environment}-docdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.docdb_instance_class
  tags               = var.tags
}


#-------------------------------------------------
# ElastiCache (Redis)
#-------------------------------------------------
resource "aws_elasticache_subnet_group" "redis" {
  name       = "mapapp-${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "redis_sg" {
  name        = "mapapp-${var.environment}-redis-sg"
  description = "Allow traffic to Redis from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 6379
    to_port         = 6379
    security_groups = [var.node_security_group_id]
  }

  tags = var.tags
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "mapapp-${var.environment}-redis"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis_sg.id]
  tags                 = var.tags
} 