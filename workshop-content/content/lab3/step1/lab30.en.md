---
title : "Step 1: Create peering between the production and DR FSxN filesystems"
weight : 81
---
::::alert{type="info" header="Cluster Peering Alternative Method"}
If you want to fully undertand the process of the file-system peering you can follow the instructions below on this page, alternativly you can use a job that will automate the process for you. If you want to use the job skip this page and [follow the instuctions on the next page](/lab3/step1/lab31).
::::
#### Create a Pod that will be able to issue ONTAP CLI commnads against both FSxN filesystems.
::::alert{type="warning" header="EKS Cluster Context Setup"}
This part of the lab is focused on our `eks-primary` cluster so make sure you set the context for kubectl to use that cluster by using the following command:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl config use-context eks-primary
:::
::::
Run the ssh pod `lab3_ssh.yaml` to login to the FSx ONTAP cli using the following:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl create -f lab3_ssh.yaml
:::
Login to the ssh pod so you can issue ONTAP CLI commands against both FSxN filesystems:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl exec --stdin --tty sshpod -- /bin/sh
:::

#### FSxN Cluster Peering:
1) Log in to the destenation DR FSxN managementIP (password provided as `fsx-password` on `terraform output`):
:::code{showCopyAction=true showLineNumbers=false language=shell}
ssh fsxadmin@<fsx-dr-management-ip>
:::
Run the `cluster_peer_destenation` (terraform output) command to peer the dr FSxN cluster with the production FSxN cluster. It should be something similar to this:
:::code{showCopyAction=true showLineNumbers=false language=shell}
cluster peer create -address-family ipv4 -peer-addrs <peer-address-1>,<peer-address-2>
:::
Log in to the source production FSxN managementIP (use the password provided by the `terraform output`):
:::code{showCopyAction=true showLineNumbers=false language=shell}
ssh fsxadmin@<fsx-management-ip>
:::
Run the `cluster_peer_source`(terraform output) command to peer the dr FSxN cluster with the production FSxN cluster. It should be something similar to this:
:::code{showCopyAction=true showLineNumbers=false language=shell}
cluster peer create -address-family ipv4 -peer-addrs <peer-address-1>,<peer-address-2>
:::
#### FSxN SVM Peering
Log in to the destenation DR FSxN managementIP (use the password provided by the `terraform output`):
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl exec --stdin --tty sshpod -- /bin/sh
ssh fsxadmin@<fsx-dr-management-ip>
:::
Run the `svm_peer_destination` (terraform output) command to peer the DR SVM with the production SVM. It should be something similar to this:
:::code{showCopyAction=true showLineNumbers=false language=shell}
vserver peer create -vserver ekssvmdr -peer-vserver ekssvm -peer-cluster <fsxn-name> -applications snapmirror
:::
Log in to the source production FSxN managementIP (use the password provided by the `terraform output`):
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl exec --stdin --tty sshpod -- /bin/sh
ssh fsxadmin@<fsx-management-ip>
:::
Run the `svm_peer_source` (terraform output) command to accept the DR peer request by the Production. It should be something similar to this

:::code{showCopyAction=true showLineNumbers=false language=shell}
vserver peer accept -vserver ekssvm -peer-vserver ekssvmdr
:::

Now that we have both FSxN file-systems and SVM peered we can start replicating PVCs between these clusters.