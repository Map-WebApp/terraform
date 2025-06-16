variable "cluster_oidc_issuer_url" {
  description = "The OIDC Identity Provider URL of the EKS cluster."
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}