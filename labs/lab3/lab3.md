# Lab 3 - Remote Disaster Recovery
Meet stricter SLAs and disaster recovery requirements by replicating data across multiple AWS regions. 

## Task 1 : Create peering between the production and DR FSxN filesystems
**Step 1:** Create a Pod that will be able to issue ONTAP CLI commnads against both FSxN filesystems.

1) Run the ssh pod [ssh.yaml](ssh.yaml) to login to the FSx ONTAP cli using the following:
```
kubectl create -f ssh.yaml
```
2) Login to the ssh pod so you can issue ONTAP CLI commands against both FSxN filesystems:
```
kubectl exec --stdin --tty sshpod -- /bin/sh
```

**Step 2:** Cluster Peering:
1) Log in to the destenation DR FSxN managementIP (use the password provided by the `terraform output`):
```
ssh fsxadmin@<dr-ip-address>
```
2). Run the `cluster_peer_destenation` (terraform output) command to peer the dr FSxN cluster with the production FSxN cluster. It should be something similar to this:
```
cluster peer create -address-family ipv4 -peer-addrs <peer-address-1>,<peer-address-2>
```
3). Log in to the source production FSxN managementIP (use the password provided by the `terraform output`):
```
ssh fsxadmin@<dr-ip-address>
```
4). Run the `cluster_peer_source`(terraform output) command to peer the dr FSxN cluster with the production FSxN cluster. It should be something similar to this:
```
cluster peer create -address-family ipv4 -peer-addrs <peer-address-1>,<peer-address-2>
```
**Step 3:** SVM Peering
1) Log in to the destenation DR FSxN managementIP (use the password provided by the `terraform output`):
```
kubectl exec --stdin --tty sshpod -- /bin/sh
ssh fsxadmin@<dr-ip-address>
```
2) Run the `svm_peer_destination` (terraform output) command to peer the DR SVM with the production SVM. It should be something similar to this:
```
vserver peer create -vserver ekssvmdr -peer-vserver ekssvm -peer-cluster <fsxn-name> -applications snapmirror
```
3) Log in to the source production FSxN managementIP (use the password provided by the `terraform output`):
```
kubectl exec --stdin --tty sshpod -- /bin/sh
ssh fsxadmin@<dr-ip-address>
```
4) Run the `svm_peer_source` (terraform output) command to accept the DR peer request by the Production. It should be something similar to this

```
vserver peer accept -vserver ekssvm -peer-vserver ekssvmdr
```
## Task 2 : Ceate Snapmirror relationships to PVCs
**Step 1:** Create Mirror relationships on the source PVCs

1) Create the Trident Snapmirror resources using [mirrorsource.yaml](mirrorsource.yaml) manifest:
```
kubectl create -f ../labs/lab3/mirrorsource.yaml -n tenant0
```
expected output:
```
tridentmirrorrelationship.trident.netapp.io/assets-share created
tridentmirrorrelationship.trident.netapp.io/data-catalog-mysql-0 created
tridentmirrorrelationship.trident.netapp.io/data-orders-mysql-0 created
tridentmirrorrelationship.trident.netapp.io/data-orders-rabbitmq-0 created
```
2) Check the mirror relationships on the source cluster:
```
kubectl get tmr -n tenant0
```
Expected outout:
```
NAME                     DESIRED STATE   LOCAL PVC                ACTUAL STATE   MESSAGE
assets-share             promoted        assets-share             promoted       
data-catalog-mysql-0     promoted        data-catalog-mysql-0     promoted       
data-orders-mysql-0      promoted        data-orders-mysql-0      promoted       
data-orders-rabbitmq-0   promoted        data-orders-rabbitmq-0   promoted       
```
3) Get the FSxN local volume handles for all PVCs:
```
kubectl get tmr -n tenant0 -o=jsonpath="{range .items[*]}[{.metadata.name},{.status.conditions[0].localVolumeHandle}]{'\n'}{end}"
```
Expected output:
```
[assets-share,ekssvm:trident_pvc_cb387eef_3fa7_46f2_b726_1682c777b1a6]
[data-catalog-mysql-0,ekssvm:trident_pvc_bfc62dea_fa19_45dd_acbd_612e4b271876]
[data-orders-mysql-0,ekssvm:trident_pvc_19880815_9777_41cf_9def_5b83e4cbbe9e]
[data-orders-rabbitmq-0,ekssvm:trident_pvc_c18a60ff_723d_45a2_b40c_4d84934d38ba]
```
