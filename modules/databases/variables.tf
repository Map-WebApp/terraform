variable "environment" {
  description = "The deployment environment (e.g., dev, prod)."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where to create the databases."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs to deploy the databases in."
  type        = list(string)
}

variable "node_security_group_id" {
  description = "The security group ID of the EKS nodes to allow database access from."
  type        = string
}

# RDS (MySQL) variables
variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes for the RDS instance."
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "The instance type for the RDS instance."
  type        = string
}

variable "db_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
}

# DocumentDB variables
variable "docdb_instance_class" {
  description = "The instance type for the DocumentDB instances."
  type        = string
}

variable "docdb_instances" {
  description = "The number of DocumentDB instances to create."
  type        = number
}

# ElastiCache (Redis) variables
variable "redis_node_type" {
  description = "The node type for the Redis cluster."
  type        = string
}

variable "redis_replicas" {
  description = "Number of read replicas for the Redis cluster. 0 creates a standalone cluster."
  type        = number
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}