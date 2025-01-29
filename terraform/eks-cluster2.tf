module "eks2" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.33.1"
  cluster_name    = local.cluster2_name
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc2.private_subnets

  enable_irsa = true
  cluster_endpoint_public_access = true
  dataplane_wait_duration = "2m"

  authentication_mode = "API"
  enable_cluster_creator_admin_permissions = true 

  vpc_id = module.vpc2.vpc_id

  eks_managed_node_group_defaults = {
    ami_type               = "AL2023_x86_64_STANDARD"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt_2.id]
  }

  eks_managed_node_groups = {

    eks-saas-dr-node-group = {
      min_size     = 2
      max_size     = 6
      desired_size = 2

      enable_bootstrap_user_data = true

      pre_bootstrap_user_data = data.cloudinit_config.cloudinit.rendered
    }
  }
}

resource "aws_eks_addon" "snapshot_controller2" {
  cluster_name = module.eks2.cluster_name
  addon_name   = "snapshot-controller"
  addon_version = "v8.0.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}