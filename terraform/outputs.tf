output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "fsx-ontap-id" {
  value = aws_fsx_ontap_file_system.eksfs.id
}

output "fsx2-ontap-id" {
  value = aws_fsx_ontap_file_system.eksfs2.id
}

output "fsx-svm-name" {
  value = aws_fsx_ontap_storage_virtual_machine.ekssvm.name
}

output "fsx-svmdr-name" {
  value = aws_fsx_ontap_storage_virtual_machine.ekssvm2.name
}

output "fsx-management-ip" {
  value = aws_fsx_ontap_file_system.eksfs.endpoints[0].management[0].ip_addresses
}

output "fsx-dr-management-ip" {
  value = aws_fsx_ontap_file_system.eksfs2.endpoints[0].management[0].ip_addresses
}

output "secret_arn" {
  value = aws_secretsmanager_secret.fsxn_password_secret.arn
}

output "fsx-password" {
  value = random_string.fsx_password.result
}

output "zz_update_kubeconfig_command" {
  # value = "aws eks update-kubeconfig --name " + module.eks.cluster_id
  value = format("%s %s %s %s", "aws eks update-kubeconfig --name", module.eks.cluster_name, "--region", var.aws_region)
}

output "zz_update_kubeconfig_command2" {
  # value = "aws eks update-kubeconfig --name " + module.eks.cluster_id
  value = format("%s %s %s %s", "aws eks update-kubeconfig --name", module.eks2.cluster_name, "--region", var.aws_region)
}

output "cluster_peer_destenation" {
  value = "cluster peer create -address-family ipv4 -peer-addrs ${join(",",aws_fsx_ontap_file_system.eksfs.endpoints[0].intercluster[0].ip_addresses)}"
}

output "cluster_peer_source" {
  value = "cluster peer create -address-family ipv4 -peer-addrs ${join(",",aws_fsx_ontap_file_system.eksfs2.endpoints[0].intercluster[0].ip_addresses)}"
}

output "svm_peer_destination" {
  value = "vserver peer create -vserver ${aws_fsx_ontap_storage_virtual_machine.ekssvm2.name} -peer-vserver ${aws_fsx_ontap_storage_virtual_machine.ekssvm.name} -peer-cluster FsxId${trim(aws_fsx_ontap_file_system.eksfs.id,"fs-")} -applications snapmirror"
}

output "svm_peer_source" {
  value = "vserver peer accept -vserver ${aws_fsx_ontap_storage_virtual_machine.ekssvm.name} -peer-vserver ${aws_fsx_ontap_storage_virtual_machine.ekssvm2.name}"
}