variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "The desired Kubernetes version for the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the EKS cluster and its nodes will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the EKS cluster and nodes."
  type        = list(string)
}

variable "eks_managed_node_groups" {
  description = "A map of managed node groups to create."
  type        = any
  default     = {}
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
