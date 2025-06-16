variable "role_name" {
  description = "The name of the IAM role to create."
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the EKS OIDC provider."
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the EKS OIDC provider."
  type        = string
}

variable "service_account_namespace" {
  description = "The Kubernetes namespace of the service account."
  type        = string
}

variable "service_account_name" {
  description = "The name of the Kubernetes service account."
  type        = string
}

variable "attach_policy_arns" {
  description = "A list of IAM policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the IAM role."
  type        = map(string)
  default     = {}
} 