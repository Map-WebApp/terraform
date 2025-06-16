output "vpc_id" {
  value = module.networking.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "jenkins_irsa_role_arn" {
  value = module.eks.jenkins_role_arn
}

output "rds_endpoint" {
  value = module.databases.rds_endpoint
}

output "docdb_endpoint" {
  value = module.databases.docdb_endpoint
}

output "redis_endpoint" {
  value = module.databases.redis_endpoint
}
