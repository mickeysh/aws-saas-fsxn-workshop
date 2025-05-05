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
