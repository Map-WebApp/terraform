#---------------------------------------------------------
# AWS Load Balancer Controller
#---------------------------------------------------------
resource "helm_release" "aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.1"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.aws_load_balancer_controller_role_arn
  }

  depends_on = [var.cluster_endpoint]
}

#---------------------------------------------------------
# AWS EFS CSI Driver
#---------------------------------------------------------
resource "helm_release" "aws_efs_csi_driver" {
  count = var.enable_efs_csi_driver ? 1 : 0

  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  version    = "2.5.6"

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.efs_csi_driver_role_arn
  }

  depends_on = [var.cluster_endpoint]
}

#---------------------------------------------------------
# Jenkins
#---------------------------------------------------------
resource "helm_release" "jenkins" {
  count = var.enable_jenkins ? 1 : 0

  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = "cicd"
  version    = "5.0.7"

  create_namespace = true

  values = [
    yamlencode({
      controller = {
        serviceAccount = {
          create = true
          name   = "jenkins"
          annotations = {
            "eks.amazonaws.com/role-arn" = var.jenkins_role_arn
          }
        }
        persistence = {
          enabled      = true
          storageClass = "efs-sc"
          size         = "10Gi"
        }
        resources = {
          requests = {
            memory = "1Gi"
            cpu    = "500m"
          }
          limits = {
            memory = "2Gi"
            cpu    = "1000m"
          }
        }
      }
    })
  ]

  depends_on = [var.cluster_endpoint, helm_release.aws_efs_csi_driver]
}

#---------------------------------------------------------
# ArgoCD
#---------------------------------------------------------
resource "helm_release" "argocd" {
  count = var.enable_argocd ? 1 : 0

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "6.0.1"

  create_namespace = true

  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
          }
        }
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]

  depends_on = [var.cluster_endpoint, helm_release.aws_load_balancer_controller]
}

#---------------------------------------------------------
# Cluster Autoscaler
#---------------------------------------------------------
resource "helm_release" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.35.0"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.cluster_autoscaler_role_arn
  }

  depends_on = [var.cluster_endpoint]
}
