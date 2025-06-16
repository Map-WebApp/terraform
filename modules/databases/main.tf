locals {
  db_subnet_ids = slice(var.private_subnet_ids, 0, 2)
}

resource "aws_db_subnet_group" "mysql" {
  name       = "mapapp-dev-mysql-sng"
  subnet_ids = local.db_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "db" {
  name        = "mapapp-dev-db-sg"
  description = "Allow EKS nodes to access DB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_db_instance" "mysql" {
  identifier         = "mapapp-dev-mysql"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  username           = var.db_username
  password           = var.db_password
  allocated_storage  = 20
  storage_type       = "gp2"
  db_subnet_group_name = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot = true
  publicly_accessible = false
  multi_az = false
  tags = var.tags
}

resource "aws_docdb_subnet_group" "docdb" {
  name       = "mapapp-dev-docdb-sng"
  subnet_ids = local.db_subnet_ids
  tags       = var.tags
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "mapapp-dev-docdb"
  master_username         = var.docdb_username
  master_password         = var.docdb_password
  db_subnet_group_name    = aws_docdb_subnet_group.docdb.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  skip_final_snapshot     = true
  tags                    = var.tags
}

resource "aws_docdb_cluster_instance" "docdb_instance" {
  identifier         = "mapapp-dev-docdb-1"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.small"
  tags               = var.tags
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "mapapp-dev-redis-sng"
  subnet_ids = local.db_subnet_ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "mapapp-dev-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.db.id]
  tags                 = var.tags
}
