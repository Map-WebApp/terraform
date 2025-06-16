output "aws_load_balancer_controller_release_name" {
  description = "The name of the AWS Load Balancer Controller Helm release."
  value       = var.enable_aws_load_balancer_controller ? helm_release.aws_load_balancer_controller[0].name : null
}

output "efs_csi_driver_release_name" {
  description = "The name of the EFS CSI Driver Helm release."
  value       = var.enable_efs_csi_driver ? helm_release.aws_efs_csi_driver[0].name : null
}

output "jenkins_release_name" {
  description = "The name of the Jenkins Helm release."
  value       = var.enable_jenkins ? helm_release.jenkins[0].name : null
}

output "argocd_release_name" {
  description = "The name of the ArgoCD Helm release."
  value       = var.enable_argocd ? helm_release.argocd[0].name : null
}

output "cluster_autoscaler_release_name" {
  description = "The name of the Cluster Autoscaler Helm release."
  value       = var.enable_cluster_autoscaler ? helm_release.cluster_autoscaler[0].name : null
}
