# This module uses the official AWS EKS module to create the cluster
# and a default managed node group.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.13.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Enable public access to the Kubernetes API server
  cluster_endpoint_public_access = true

  # Create a default managed node group
  eks_managed_node_groups = {
    main-nodes = {
      instance_types = [var.node_instance_type]
      desired_size   = var.node_desired_capacity
      min_size       = 1
      max_size       = var.node_desired_capacity + 2 # Allow some room for scaling

      # Associate the SSH key pair
      key_name = var.key_name
      
      # Add proper naming
      name = "${var.cluster_name}-nodes"
    }
  }

  # Enable IAM Roles for Service Accounts (IRSA)
  enable_irsa = true

  tags = var.tags
}
