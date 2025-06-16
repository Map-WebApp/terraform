# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

# EKS Outputs
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

# Database Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.databases.rds_endpoint
  sensitive   = true
}

output "docdb_endpoint" {
  description = "DocumentDB cluster endpoint"
  value       = module.databases.docdb_endpoint
  sensitive   = true
}

output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = module.databases.redis_endpoint
  sensitive   = true
}

# EFS Outputs
output "efs_file_system_id" {
  description = "ID of the EFS file system"
  value       = module.efs.file_system_id
}

# IAM Outputs
output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.iam.aws_load_balancer_controller_role_arn
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of the Cluster Autoscaler IAM role"
  value       = module.iam.cluster_autoscaler_role_arn
}

# Key Pair Output
output "key_pair_name" {
  description = "Name of the EC2 Key Pair"
  value       = module.keypair.key_name
}

# Production Notes
output "production_notes" {
  description = "Important notes for production environment"
  value = <<-EOT
    Production Environment Setup Complete!
    
    Key Features:
    - Multi-AZ RDS MySQL for high availability
    - DocumentDB cluster with 3 instances
    - Redis with 2 replicas for HA
    - EKS nodes across 3 availability zones
    - Multiple NAT Gateways for redundancy
    - Cluster Autoscaler for dynamic scaling
    
    Security Notes:
    - No CI/CD tools (Jenkins/ArgoCD) deployed on production
    - All databases are in private subnets
    - Encryption enabled for all storage services
    
    Next Steps:
    1. Configure ArgoCD on DEV to deploy to this PROD cluster
    2. Set up monitoring and alerting
    3. Configure backup policies for databases
    4. Review and update security groups as needed
    EOT
}

# Kubeconfig command
output "kubeconfig_command" {
  description = "Command to configure kubectl for production cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
