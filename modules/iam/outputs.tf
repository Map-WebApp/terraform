output "jenkins_role_arn" {
  description = "The ARN of the Jenkins IAM role."
  value       = module.jenkins_irsa.iam_role_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "The ARN of the AWS Load Balancer Controller IAM role."
  value       = module.aws_load_balancer_controller_irsa.iam_role_arn
}

output "efs_csi_driver_role_arn" {
  description = "The ARN of the EFS CSI Driver IAM role."
  value       = module.efs_csi_driver_irsa.iam_role_arn
}

output "cluster_autoscaler_role_arn" {
  description = "The ARN of the Cluster Autoscaler IAM role."
  value       = module.cluster_autoscaler_irsa.iam_role_arn
}