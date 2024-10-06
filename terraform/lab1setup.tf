resource "local_file" "trident_backendns_yaml_lab1" {
  filename = "${path.module}/../labs/lab1/backends.yaml"
  content = templatefile("${path.module}/../labs/lab1/tmplt/backends.yaml.tpl",
    {
      fs_id      = aws_fsx_ontap_file_system.eksfs.id
      fs_svm     = aws_fsx_ontap_storage_virtual_machine.ekssvm.name
      secret_arn = aws_secretsmanager_secret.fsxn_password_secret.arn
    }
  )
}

resource "local_file" "trident_svc_ldb_yaml_lab1" {
  filename = "${path.module}/../labs/lab1/svc_ldb.yaml"
  content = templatefile("${path.module}/../labs/lab1/tmplt/svc.yaml.tpl",
    {
      loadBalancerSourceRanges = "${data.http.ip.response_body}/32"
    }
  )
}

resource "local_file" "trident_sample_yaml_lab1" {
  filename = "${path.module}/../labs/lab1/sample.yaml"
  content = templatefile("${path.module}/../labs/lab1/tmplt/sample.yaml.tpl",
    {
      ng2_name = regex("eks-saas-node.*", module.eks.eks_managed_node_groups.eks-saas-node-group2.node_group_id)
    }
  )
}

