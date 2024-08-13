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
1) Log in to the destenation DR FSxN managementIP (password provided as `fsx-password` on `terraform output`):
```
ssh fsxadmin@<fsx-dr-management-ip>
```
2). Run the `cluster_peer_destenation` (terraform output) command to peer the dr FSxN cluster with the production FSxN cluster. It should be something similar to this:
```
cluster peer create -address-family ipv4 -peer-addrs <peer-address-1>,<peer-address-2>
```
3). Log in to the source production FSxN managementIP (use the password provided by the `terraform output`):
```
ssh fsxadmin@<fsx-management-ip>
```
4). Run the `cluster_peer_source`(terraform output) command to peer the dr FSxN cluster with the production FSxN cluster. It should be something similar to this:
```
cluster peer create -address-family ipv4 -peer-addrs <peer-address-1>,<peer-address-2>
```
**Step 3:** SVM Peering
1) Log in to the destenation DR FSxN managementIP (use the password provided by the `terraform output`):
```
kubectl exec --stdin --tty sshpod -- /bin/sh
ssh fsxadmin@<fsx-dr-management-ip>
```
2) Run the `svm_peer_destination` (terraform output) command to peer the DR SVM with the production SVM. It should be something similar to this:
```
vserver peer create -vserver ekssvmdr -peer-vserver ekssvm -peer-cluster <fsxn-name> -applications snapmirror
```
3) Log in to the source production FSxN managementIP (use the password provided by the `terraform output`):
```
kubectl exec --stdin --tty sshpod -- /bin/sh
ssh fsxadmin@<fsx-management-ip>
```
4) Run the `svm_peer_source` (terraform output) command to accept the DR peer request by the Production. It should be something similar to this

```
vserver peer accept -vserver ekssvm -peer-vserver ekssvmdr
```
## Task 2 : Ceate Snapmirror relationships to PVCs
**Step 1:** Create Mirror relationships on the source PVCs

1) Create the Trident Snapmirror resources using [mirrorsource.yaml](mirrorsource.yaml) manifest:
```
kubectl create -f mirrorsource.yaml -n tenant0
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
4) Change you kubectl context to the DR cluster. You can use the terraform output `zz_update_kubeconfig_command2` to do it. 

5) Create the Trident Snapmirror resources on the destination cluster using [mirrordest.yaml](mirrordest.yaml) manifest. Make sure you update all the `<volumeHandle>` which the source volumes handles from section 3. 
```yaml
kind: TridentMirrorRelationship
apiVersion: trident.netapp.io/v1
metadata:
  name: assets-share 
spec:
  state: established
  volumeMappings:
  - localPVCName: assets-share <=== Volume handle should mach the local PVC name
    remoteVolumeHandle: "<volumeHandle>" <<=== Update here
``` 
Run the following to create the mirror relationship:
```bash
> kubectl create -f mirrordest.yaml -n tenant0
tridentmirrorrelationship.trident.netapp.io/assets-share created
tridentmirrorrelationship.trident.netapp.io/data-catalog-mysql-0 created
tridentmirrorrelationship.trident.netapp.io/data-orders-mysql-0 created
tridentmirrorrelationship.trident.netapp.io/data-orders-rabbitmq-0 created
```

6) Create the destination PVCs to replicate the data to:
```bash
> kubectl create -f pvcdest.yaml -n tenant0
persistentvolumeclaim/assets-share created
persistentvolumeclaim/data-catalog-mysql-0 created
persistentvolumeclaim/data-orders-mysql-0 created
persistentvolumeclaim/data-orders-rabbitmq-0 created
```

7) Check the mirror relationships on the destination cluster:
```bash
> kubectl get tmr -n tenant0
NAME                     DESIRED STATE   LOCAL PVC                ACTUAL STATE   MESSAGE
assets-share             established     assets-share             established    
data-catalog-mysql-0     established     data-catalog-mysql-0     established    
data-orders-mysql-0      established     data-orders-mysql-0      established    
data-orders-rabbitmq-0   established     data-orders-rabbitmq-0   established                    
```

## Task 3 : Activate DR cluster
1) Stop the mirroring and make the local volume on the DR cluster R/W and mountable. Use [mirrordestdr.yaml](mirrordestdr.yaml) manifest to change the mirror relationship from `established` to `promoted`.
```bash
> kubectl apply -n tenant0 -f mirrordestdr.yaml
tridentmirrorrelationship.trident.netapp.io/assets-share configured
tridentmirrorrelationship.trident.netapp.io/data-catalog-mysql-0 configured
tridentmirrorrelationship.trident.netapp.io/data-orders-mysql-0 configured
tridentmirrorrelationship.trident.netapp.io/data-orders-rabbitmq-0 configured
```

2) Validate that the mirror relationship actual state was set to promoted (during the process the actual state might be `promoting` before changing to `promoted`)
```bash
> kubectl get tmr -n tenant0
NAME                     DESIRED STATE   LOCAL PVC                ACTUAL STATE   MESSAGE
assets-share             promoted        assets-share             promoted       
data-catalog-mysql-0     promoted        data-catalog-mysql-0     promoted       
data-orders-mysql-0      promoted        data-orders-mysql-0      promoted       
data-orders-rabbitmq-0   promoted        data-orders-rabbitmq-0   promoted       
```
3) Deploy the Application on the DR site:
```bash
> kubectl create -f sample.yaml
serviceaccount/catalog created
secret/catalog-db created
configmap/catalog created
service/catalog-mysql created
service/catalog created
deployment.apps/catalog created
statefulset.apps/catalog-mysql created
serviceaccount/carts created
configmap/carts created
service/carts-dynamodb created
service/carts created
deployment.apps/carts created
deployment.apps/carts-dynamodb created
serviceaccount/orders created
secret/orders-db created
secret/orders-rabbitmq created
configmap/orders created
service/orders-mysql created
service/orders-rabbitmq created
service/orders created
deployment.apps/orders created
statefulset.apps/orders-mysql created
statefulset.apps/orders-rabbitmq created
serviceaccount/checkout created
configmap/checkout created
service/checkout-redis created
service/checkout created
deployment.apps/checkout created
deployment.apps/checkout-redis created
serviceaccount/assets created
configmap/assets created
service/assets created
deployment.apps/assets created
serviceaccount/ui created
configmap/ui created
service/ui created
deployment.apps/ui created
```

4) Check sample application is running:
```bash
> kubectl get pods -n tenant0
NAME                              READY   STATUS    RESTARTS        AGE
assets-6694b7ccff-hzhl4           1/1     Running   0               2m31s
carts-8c454c85c-5ttvm             1/1     Running   1 (77s ago)     2m35s
carts-dynamodb-57dc7d97d5-5kqnf   1/1     Running   0               2m35s
catalog-6ffdd78f77-j9w2n          1/1     Running   4 (90s ago)     2m36s
catalog-mysql-0                   1/1     Running   0               2m36s
checkout-8b8548dd8-t8nrv          1/1     Running   0               2m32s
checkout-redis-78f4d66577-gsw2q   1/1     Running   0               2m32s
orders-6574497d84-6qgqk           1/1     Running   2 (64s ago)     2m34s
orders-mysql-0                    1/1     Running   1 (90s ago)     2m34s
orders-rabbitmq-0                 1/1     Running   0               2m33s
sshpod                            1/1     Running   145 (17m ago)   6d1h
ui-774d676c59-6ldx7               1/1     Running   0               2m31s
```

5) Check the assets service volume content. You should see 6 images as it was before the images download:
```bash
kubectl exec -n tenant0 --stdin deployment/assets -- bash -c 'ls /usr/share/nginx/html/assets'
chrono_classic.jpg
gentleman.jpg
pocket_watch.jpg
smart_1.jpg
smart_2.jpg
wood_watch.jpg
```