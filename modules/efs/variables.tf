variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs to create EFS mount targets in."
  type        = list(string)
}

variable "node_sg_id" {
  description = "The security group ID of the EKS nodes to allow access from."
  type        = string
}

variable "efs_name" {
  description = "The name for the EFS file system."
  type        = string
  default     = "mapapp-efs"
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
} 