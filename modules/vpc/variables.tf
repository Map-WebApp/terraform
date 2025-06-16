variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "A list of Availability Zones to deploy in."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Set to true to create a NAT Gateway."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Set to true to create a single NAT Gateway for cost savings."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
