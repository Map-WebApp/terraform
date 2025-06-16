locals {
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_oidc_issuer_url, "https://", "")}"
}

data "aws_caller_identity" "current" {}

#-------------------------------------------------
# IAM Role for Jenkins
#-------------------------------------------------
module "jenkins_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "mapapp-jenkins-role"

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["cicd:jenkins"]
    }
  }

  role_policy_arns = {
    ecr_power_user = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  }

  tags = var.tags
}

#-------------------------------------------------
# IAM Role for AWS Load Balancer Controller
#-------------------------------------------------
module "aws_load_balancer_controller_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "mapapp-aws-load-balancer-controller-role"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = var.tags
}

#-------------------------------------------------
# IAM Role for EFS CSI Driver
#-------------------------------------------------
module "efs_csi_driver_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "mapapp-efs-csi-driver-role"

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

#-------------------------------------------------
# IAM Role for Cluster Autoscaler
#-------------------------------------------------
module "cluster_autoscaler_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "mapapp-cluster-autoscaler-role"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [var.cluster_name]

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }

  tags = var.tags
}