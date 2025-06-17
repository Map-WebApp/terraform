variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the EKS cluster will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster and nodes."
  type        = list(string)
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS worker nodes."
  type        = string
}

variable "node_desired_capacity" {
  description = "Desired number of worker nodes."
  type        = number
}

variable "key_name" {
  description = "The name of the SSH key pair to associate with the EKS worker nodes."
  type        = string
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether to grant cluster-admin permissions to the IAM principal that created the cluster."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default     = {}
}
