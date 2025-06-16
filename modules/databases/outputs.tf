output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "docdb_endpoint" {
  value = aws_docdb_cluster.docdb.endpoint
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}
