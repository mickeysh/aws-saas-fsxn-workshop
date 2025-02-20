module "aws_lb_controller_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.10.0"
  name = "AmazonEKS_LBC_Role_${random_string.suffix.result}"

  attach_aws_lb_controller_policy = true
}

resource "aws_eks_pod_identity_association" "aws-lb-pod-identity-association1" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = module.aws_lb_controller_pod_identity.iam_role_arn
}

resource "aws_eks_pod_identity_association" "aws-lb-pod-identity-association2" {
  cluster_name    = module.eks2.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = module.aws_lb_controller_pod_identity.iam_role_arn
}


# module "lb_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "5.46.0"

#   role_name                              = "AmazonEKS_LBC_Role_${random_string.suffix.result}"
#   attach_load_balancer_controller_policy = true

#   oidc_providers = {
#     eks1 = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#     }
#     eks2 = {
#       provider_arn               = module.eks2.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#     }
#   }
# }

# resource "kubernetes_service_account" "lbc_service-account" {
#   provider = kubernetes.cluster1

#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     labels = {
#       "app.kubernetes.io/name"      = "aws-load-balancer-controller"
#       "app.kubernetes.io/component" = "controller"
#     }
#     annotations = {
#       # "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
#       "eks.amazonaws.com/sts-regional-endpoints" = "true"
#     }
#   }
# }

# resource "kubernetes_service_account" "lbc_service-account2" {
#   provider = kubernetes.cluster2

#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     labels = {
#       "app.kubernetes.io/name"      = "aws-load-balancer-controller"
#       "app.kubernetes.io/component" = "controller"
#     }
#     annotations = {
#       # "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
#       "eks.amazonaws.com/sts-regional-endpoints" = "true"
#     }
#   }
# }

resource "helm_release" "lb" {
  provider = helm.cluster1

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    aws_eks_pod_identity_association.aws-lb-pod-identity-association1
  ]

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "disableRestrictedSecurityGroupRules"
    value = "true"
  }
}

resource "helm_release" "lb2" {
  provider = helm.cluster2

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    aws_eks_pod_identity_association.aws-lb-pod-identity-association2
  ]

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = module.eks2.cluster_name
  }

  set {
    name  = "disableRestrictedSecurityGroupRules"
    value = "true"
  }
}
