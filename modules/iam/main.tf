locals {
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_oidc_issuer_url, "https://", "")}"
}

data "aws_caller_identity" "current" {}

data "http" "load_balancer_controller_policy_json" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "load_balancer_controller" {
  name_prefix = "mapapp-alb-controller-policy-"
  description = "IAM policy for the AWS Load Balancer Controller"
  policy      = data.http.load_balancer_controller_policy_json.response_body
  tags        = var.tags
}

#-------------------------------------------------
# IAM Role for Jenkins
#-------------------------------------------------
module "jenkins_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name_prefix = "mapapp-jenkins-role-"
  role_policy_arns = {
    ecr_power_user = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  }

  oidc_providers = {
    main = {
      provider_arn               = var.cluster_oidc_issuer_url
      namespace_service_accounts = ["cicd:jenkins"]
    }
  }

  tags = var.tags
}

#-------------------------------------------------
# IAM Role for AWS Load Balancer Controller
#-------------------------------------------------
module "aws_load_balancer_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name_prefix = "mapapp-alb-ctrl-role-"
  role_policy_arns = {
    alb_controller = aws_iam_policy.load_balancer_controller.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.cluster_oidc_issuer_url
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = var.tags
}

#-------------------------------------------------
# IAM Role for EFS CSI Driver
#-------------------------------------------------
module "efs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name_prefix      = "mapapp-efs-csi-driver-role-"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.cluster_oidc_issuer_url
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

#-------------------------------------------------
# IAM Role for Cluster Autoscaler
#-------------------------------------------------
module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name_prefix                 = "mapapp-cluster-autoscaler-role-"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [var.cluster_name]

  oidc_providers = {
    main = {
      provider_arn               = var.cluster_oidc_issuer_url
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
  tags = var.tags
}