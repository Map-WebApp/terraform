variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "mapapp"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for cost savings in dev"
  type        = bool
  default     = true
}

# EKS Configuration
variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "eks_instance_type" {
  description = "Instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "eks_desired_nodes" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "eks_min_nodes" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "eks_max_nodes" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

# Database Configuration
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = false
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
}

variable "docdb_instance_class" {
  description = "DocumentDB instance class"
  type        = string
  default     = "db.t4g.medium"
}

variable "docdb_instances" {
  description = "Number of DocumentDB instances"
  type        = number
  default     = 1
}

variable "docdb_username" {
  description = "DocumentDB master username"
  type        = string
  default     = "admin"
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_replicas" {
  description = "Number of Redis replicas"
  type        = number
  default     = 0
}

# SSH Key Configuration
variable "public_key" {
  description = "Public key for EC2 instances"
  type        = string
  default     = ""
}
