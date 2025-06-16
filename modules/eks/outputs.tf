output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider."
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "The URL of the OIDC provider."
  value       = module.eks.oidc_provider
}
