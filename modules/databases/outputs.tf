output "rds_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.mysql.endpoint
}

output "docdb_endpoint" {
  description = "The endpoint of the DocumentDB cluster."
  value       = aws_docdb_cluster.docdb.endpoint
}

output "redis_endpoint" {
  description = "The endpoint of the Redis cluster."
  value = var.redis_replicas > 0 ? (
    aws_elasticache_replication_group.redis_ha[0].primary_endpoint_address
  ) : (
    aws_elasticache_cluster.redis_standalone[0].cache_nodes[0].address
  )
}

output "db_security_group_id" {
  description = "The ID of the database security group."
  value       = aws_security_group.db_sg.id
}
