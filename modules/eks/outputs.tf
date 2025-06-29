output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's API server."
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC Identity Provider URL for the cluster, used for IRSA."
  value       = module.eks.oidc_provider
}

output "node_security_group_id" {
  description = "The ID of the security group attached to the EKS worker nodes."
  value       = module.eks.node_security_group_id
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider."
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "The URL of the OIDC provider."
  value       = module.eks.oidc_provider
}

output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data required to communicate with the cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_ca_certificate" {
  description = "Base64 encoded cluster CA data."
  value       = module.eks.cluster_certificate_authority_data
}
