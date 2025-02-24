## Create peering between the production and DR FSxN filesystems
In this part of the lab we will create a [cluster peering relationship](https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/migrating-fsx-ontap-snapmirror.html#cluster-peering)  between the `eks-primary` and the `eks-dr` clusters and [SVM peering relationship](https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/migrating-fsx-ontap-snapmirror.html#svm-peering) between relevant SVMs on each cluster (`ekssvm` and `ekssvm2` respectively). This is required once per file-system pair and enables creating the mirror relationships for volumes these file-systems.  

> [!IMPORTANT]
> This part of the lab is focused on our `eks-primary` cluster so make sure you set the context for kubectl to use that cluster by using the following command:
> ```shell
> kubectl config use-context eks-primary
> ```

### Step 1 - Create a Pod that will be able to issue ONTAP CLI commnads against both FSxN filesystems.

Run the ssh pod [ssh.yaml](ssh.yaml) to login to the FSx ONTAP cli using the following:
```
kubectl create -f ssh.yaml
```
Login to the ssh pod so you can issue ONTAP CLI commands against both FSxN filesystems:
```
kubectl exec --stdin --tty sshpod -- /bin/sh
```

### Step 2 - Cluster Peering:
1) Log in to the destenation DR FSxN managementIP (password provided as `fsx-password` on `terraform output`):
```
ssh fsxadmin@<fsx-dr-management-ip>
```
Run the `cluster_peer_destenation` (terraform output) command to peer the dr FSxN cluster with the production FSxN cluster. It should be something similar to this:
```
cluster peer create -address-family ipv4 -peer-addrs <peer-address-1>,<peer-address-2>
```
Log in to the source production FSxN managementIP (use the password provided by the `terraform output`):
```
ssh fsxadmin@<fsx-management-ip>
```
Run the `cluster_peer_source`(terraform output) command to peer the dr FSxN cluster with the production FSxN cluster. It should be something similar to this:
```
cluster peer create -address-family ipv4 -peer-addrs <peer-address-1>,<peer-address-2>
```
### Step 3 - SVM Peering
Log in to the destenation DR FSxN managementIP (use the password provided by the `terraform output`):
```
kubectl exec --stdin --tty sshpod -- /bin/sh
ssh fsxadmin@<fsx-dr-management-ip>
```
Run the `svm_peer_destination` (terraform output) command to peer the DR SVM with the production SVM. It should be something similar to this:
```
vserver peer create -vserver ekssvmdr -peer-vserver ekssvm -peer-cluster <fsxn-name> -applications snapmirror
```
Log in to the source production FSxN managementIP (use the password provided by the `terraform output`):
```
kubectl exec --stdin --tty sshpod -- /bin/sh
ssh fsxadmin@<fsx-management-ip>
```
Run the `svm_peer_source` (terraform output) command to accept the DR peer request by the Production. It should be something similar to this

```
vserver peer accept -vserver ekssvm -peer-vserver ekssvmdr
```