## Ceate Snapmirror relationships to PVCs
Next, we'll finish establishing the snapmirror relationship on the buy creating the Trident Mirror Relationship (TMR) on the `eks-dr` cluster. 

> [!IMPORTANT]
> This part of the lab is focused on our `eks-dr` cluster so make sure you set the context for kubectl to use that cluster by using the following command:
> ```shell
> kubectl config use-context eks-dr
> ```

### Step 5 - Create the snapmirror relationship on the DR cluster
Create the Trident Snapmirror resources on the destination cluster using [mirrordest.yaml](mirrordest.yaml) manifest. 
> [!IMPORTANT]
> Make sure you update all the `<volumeHandle>` with the source volumes handles the previous step (each handle on the list corresponds with the PVC name)
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

```shell
kubectl create -f mirrordest.yaml -n tenant0
```
Expected output:
```shell
tridentmirrorrelationship.trident.netapp.io/assets-share created
tridentmirrorrelationship.trident.netapp.io/data-catalog-mysql-0 created
tridentmirrorrelationship.trident.netapp.io/data-orders-mysql-0 created
tridentmirrorrelationship.trident.netapp.io/data-orders-rabbitmq-0 created
```

Create the destination PVCs to replicate the data to:
```shell
kubectl create -f pvcdest.yaml -n tenant0
```
```shell
persistentvolumeclaim/assets-share created
persistentvolumeclaim/data-catalog-mysql-0 created
persistentvolumeclaim/data-orders-mysql-0 created
persistentvolumeclaim/data-orders-rabbitmq-0 created
```

Check the mirror relationships on the destination cluster:
```shell
kubectl get tmr -n tenant0
```
Expected output:
```shell
NAME                     DESIRED STATE   LOCAL PVC                ACTUAL STATE   MESSAGE
assets-share             established     assets-share             established    
data-catalog-mysql-0     established     data-catalog-mysql-0     established    
data-orders-mysql-0      established     data-orders-mysql-0      established    
data-orders-rabbitmq-0   established     data-orders-rabbitmq-0   established                    
```