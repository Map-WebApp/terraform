module "networking" {
  source = "./modules/networking"

  vpc_cidr = var.vpc_cidr
  azs      = var.azs
  tags     = var.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.cluster_version

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  azs                = var.azs
  tags               = var.tags
}

module "databases" {
  source = "./modules/databases"

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  db_username        = var.db_username
  db_password        = var.db_password
  tags               = var.tags
}
