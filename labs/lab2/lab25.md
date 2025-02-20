## Restore the product catalog
In order to restore the catalog to the state it was before the update we'll need to revert both the catalog and assets service to the point in time copy in the `VolumeSnapshot` we created. 

We'll use NetApp trident's and FSxN capabilities to restore from Snapshot in place by using the `TridentActionSnapshotRestore` CRD. For that we'll need a short downtime for our catalog and assets services.  
### Step 6 - Scaledown the assts and catalog services
Scale down the number of active pods shutdown the assets service:
```
kubectl scale deploy assets -n tenant0 --replicas=0
```
Expected output:
```shell
deployment.apps/assets scaled
```
Check number of Pods in service is zero:
```
kubectl get deploy assets -n tenant0
```
Expected output:
```
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
assets           0/0     0            0           28h
```

Scale down the number of active pods shutdown the catalog mysql service:
```
kubectl scale statefulset catalog-mysql -n tenant0 --replicas=0
```
Expected output:
`statefulset.apps/catalog-mysql scaled`

> **IMPORTANT**: In some cases the PVC of the statefulset doesn't release the VolumeAttachment from the node. Please verify it does by using `kubectl get volumeattachment -n tenant0`. If the attachment of the relevant PV is there use this command to remove it `kubectl delete volumeattachment <attachment-name> -n tenant0`

Check number of Pods in service is zero:
```
kubectl get statefulset catalog-mysql -n tenant0
```
Expected output:
`NAME            READY   AGE
catalog-mysql   0/0     28h
`

### Step 7 - In-place restore from `VolumeSnapshot`
Run restore in place using [snap-restore.yaml](snap-restore.yaml)
```
kubectl create -f snap-restore.yaml
```
Expected output:
```shell
tridentactionsnapshotrestore.trident.netapp.io/assets-share created
tridentactionsnapshotrestore.trident.netapp.io/data-catalog-mysql-0 created
```

### Step 8 - Restart the assets and catalog services
Restart the assets pods:
```
kubectl scale deploy assets -n tenant0 --replicas=1
```
Expected output:
```shell
deployment.apps/assets scaled
```

Restart the catalog mysql db pods:
```
kubectl scale statefulset catalog-mysql -n tenant0 --replicas=1
```
Expected output:
```shell
statefulset.apps/catalog-mysql scaled
```