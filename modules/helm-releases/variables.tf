variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the EKS cluster for dependency management."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources are deployed."
  type        = string
}

variable "eks_dependency" {
  description = "EKS module dependency to ensure cluster is ready before Helm charts are installed."
  type        = any
  default     = null
}

# Enable/disable flags for each component
variable "enable_aws_load_balancer_controller" {
  description = "Whether to deploy AWS Load Balancer Controller."
  type        = bool
  default     = false
}

variable "enable_efs_csi_driver" {
  description = "Whether to deploy AWS EFS CSI Driver."
  type        = bool
  default     = false
}

variable "enable_jenkins" {
  description = "Whether to deploy Jenkins."
  type        = bool
  default     = false
}

variable "enable_argocd" {
  description = "Whether to deploy ArgoCD."
  type        = bool
  default     = false
}

variable "enable_cluster_autoscaler" {
  description = "Whether to deploy Cluster Autoscaler."
  type        = bool
  default     = false
}

# IAM Role ARNs for service accounts
variable "aws_load_balancer_controller_role_arn" {
  description = "The ARN of the IAM role for AWS Load Balancer Controller."
  type        = string
  default     = ""
}

variable "efs_csi_driver_role_arn" {
  description = "The ARN of the IAM role for EFS CSI Driver."
  type        = string
  default     = ""
}

variable "jenkins_role_arn" {
  description = "The ARN of the IAM role for Jenkins."
  type        = string
  default     = ""
}

variable "cluster_autoscaler_role_arn" {
  description = "The ARN of the IAM role for Cluster Autoscaler."
  type        = string
  default     = ""
}
