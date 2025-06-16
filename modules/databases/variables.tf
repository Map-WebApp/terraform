variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "docdb_username" {
  type        = string
  description = "Username for DocumentDB"
}

variable "docdb_password" {
  type        = string
  description = "Password for DocumentDB"
  sensitive   = true
}

variable "eks_node_security_group_id" {
  type        = string
  description = "The security group ID of the EKS nodes"
}

variable "tags" {
  type = map(string)
}
