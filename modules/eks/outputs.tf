output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "jenkins_role_arn" {
  value = aws_iam_role.jenkins_irsa.arn
}
