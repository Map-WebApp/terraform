output "rds_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.mysql.endpoint
  sensitive   = true
}

output "docdb_endpoint" {
  description = "The endpoint of the DocumentDB cluster."
  value       = aws_docdb_cluster.docdb.endpoint
  sensitive   = true
}

output "redis_endpoint" {
  description = "The endpoint of the Redis cluster."
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
  sensitive   = true
}
