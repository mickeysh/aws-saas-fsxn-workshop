resource "helm_release" "trident" {
  provider = helm.cluster1
  name             = "trident-operator"
  namespace        = "trident"
  create_namespace = true
  description      = null
  chart            = "trident-operator"
  version          = "100.2406.1"
  repository       = "https://netapp.github.io/trident-helm-chart"
  values           = [file("${path.module}/values.yaml")]

  set {
    name = "cloudIdentity"
    value = "'eks.amazonaws.com/role-arn: ${module.iam_iam-role-for-service-accounts-eks.iam_role_arn}'"
  }

}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [helm_release.trident, helm_release.trident2]

  create_duration = "30s"
}

resource "kubectl_manifest" "trident_backend_config_nas" {
  provider = kubectl.cluster1
  depends_on = [time_sleep.wait_30_seconds]
  yaml_body = templatefile("${path.module}/../manifests/backendnas.yaml.tpl",
    {
      fs_id      = aws_fsx_ontap_file_system.eksfs.id
      fs_svm     = aws_fsx_ontap_storage_virtual_machine.ekssvm.name
      secret_arn = aws_secretsmanager_secret.fsxn_password_secret.arn
    }
  )
}

resource "kubectl_manifest" "trident_backend_config_san" {
  provider = kubectl.cluster1
  depends_on = [time_sleep.wait_30_seconds]
  yaml_body = templatefile("${path.module}/../manifests/backendsan.yaml.tpl",
    {
      fs_id      = aws_fsx_ontap_file_system.eksfs.id
      fs_svm     = aws_fsx_ontap_storage_virtual_machine.ekssvm.name
      secret_arn = aws_secretsmanager_secret.fsxn_password_secret.arn
    }
  )
}

resource "kubectl_manifest" "trident_storage_class_nas" {
  provider = kubectl.cluster1
  depends_on = [kubectl_manifest.trident_backend_config_nas]
  yaml_body  = file("${path.module}/../manifests/storageclass.yaml")
}

resource "kubectl_manifest" "trident_storage_class_san" {
  provider = kubectl.cluster1
  depends_on = [kubectl_manifest.trident_backend_config_san]
  yaml_body  = file("${path.module}/../manifests/storageclasssan.yaml")
}

resource "helm_release" "trident2" {
  provider = helm.cluster2
  name             = "trident-operator"
  namespace        = "trident"
  create_namespace = true
  description      = null
  chart            = "trident-operator"
  version          = "100.2406.1"
  repository       = "https://netapp.github.io/trident-helm-chart"
  values           = [file("${path.module}/values.yaml")]

  set {
    name = "cloudIdentity"
    value = "'eks.amazonaws.com/role-arn: ${module.iam_iam-role-for-service-accounts-eks.iam_role_arn}'"
  }

}

resource "kubectl_manifest" "trident_backend_config2_nas" {
  provider = kubectl.cluster2
  depends_on = [time_sleep.wait_30_seconds]
  yaml_body = templatefile("${path.module}/../manifests/backendnas.yaml.tpl",
    {
      fs_id      = aws_fsx_ontap_file_system.eksfs2.id
      fs_svm     = aws_fsx_ontap_storage_virtual_machine.ekssvm2.name
      secret_arn = aws_secretsmanager_secret.fsxn_password_secret.arn
    }
  )
}

resource "kubectl_manifest" "trident_backend_config2_san" {
  provider = kubectl.cluster2
  depends_on = [time_sleep.wait_30_seconds]
  yaml_body = templatefile("${path.module}/../manifests/backendsan.yaml.tpl",
    {
      fs_id      = aws_fsx_ontap_file_system.eksfs2.id
      fs_svm     = aws_fsx_ontap_storage_virtual_machine.ekssvm2.name
      secret_arn = aws_secretsmanager_secret.fsxn_password_secret.arn
    }
  )
}

resource "kubectl_manifest" "trident_storage_class2_nas" {
  provider = kubectl.cluster2
  depends_on = [kubectl_manifest.trident_backend_config2_nas]
  yaml_body  = file("${path.module}/../manifests/storageclass.yaml")
}

resource "kubectl_manifest" "trident_storage_class2_san" {
  provider = kubectl.cluster2
  depends_on = [kubectl_manifest.trident_backend_config2_san]
  yaml_body  = file("${path.module}/../manifests/storageclasssan.yaml")
}

resource "kubernetes_namespace_v1" "tenant0" {
  provider = kubernetes.cluster1
  metadata {
    name = "tenant1"
  }
  
}

data "kubectl_path_documents" "sample_app_tenant0" {
    pattern = "../manifests/sample.yaml"
}

resource "kubectl_manifest" "sample_app_tenant0" {
  provider = kubectl.cluster1
  override_namespace = "tenant1"
  depends_on = [kubectl_manifest.trident_storage_class_san, kubectl_manifest.trident_storage_class_nas,kubernetes_namespace_v1.tenant0]
  for_each  = toset(data.kubectl_path_documents.sample_app_tenant0.documents)
  yaml_body  = each.value
}