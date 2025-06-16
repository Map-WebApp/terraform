variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "azs" {
  description = "List of Availability Zones to use"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "mapapp"
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
  default     = "mapapp-dev"
}

variable "db_username" {
  type        = string
  default     = "mapapp_admin"
  description = "Username for RDS MySQL"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Password for RDS MySQL (dev only)"
}

variable "docdb_username" {
  type        = string
  description = "Username for DocumentDB"
}

variable "docdb_password" {
  type        = string
  sensitive   = true
  description = "Password for DocumentDB (dev only)"
}
