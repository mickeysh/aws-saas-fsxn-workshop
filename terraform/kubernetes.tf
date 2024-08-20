# # Kubernetes provider
# # https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
  alias = "cluster1"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
  alias = "cluster1"
}

provider "kubectl" {
  apply_retry_count = 15
  
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
  alias = "cluster1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks2.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks2.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks2.token
  alias = "cluster2"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks2.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks2.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks2.token
  }
  alias = "cluster2"
}

provider "kubectl" {
  apply_retry_count = 15

  host                   = data.aws_eks_cluster.eks2.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks2.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks2.token
  load_config_file       = false
  alias = "cluster2"
}