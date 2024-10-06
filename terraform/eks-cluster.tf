module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.5.0"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc.private_subnets

  enable_irsa = true
  cluster_endpoint_public_access = true
  dataplane_wait_duration = "2m"

  authentication_mode = "API"
  enable_cluster_creator_admin_permissions = true 

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {

    eks-saas-node-group = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      
      labels = {
        TenantName = "nodeGroupTenant0" 
      }

      subnet_ids = [module.vpc.private_subnets[0]]
      enable_bootstrap_user_data = true

      pre_bootstrap_user_data = data.cloudinit_config.cloudinit.rendered
    }

    eks-saas-node-group2 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2

      labels = {
        TenantName  = "nodeGroupTenant1"
      }

      subnet_ids = [module.vpc.private_subnets[1]]
      enable_bootstrap_user_data = true

      pre_bootstrap_user_data = data.cloudinit_config.cloudinit.rendered
    }
  }
}

data "cloudinit_config" "cloudinit" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = file("scripts/iscsi.sh")
  }
}

resource "aws_eks_addon" "snapshot_controller" {
  cluster_name = module.eks.cluster_name
  addon_name   = "snapshot-controller"
  addon_version = "v8.0.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}
