---
title : "Step 4: Restore the product catalog"
weight : 75
---
In order to restore the catalog to the state it was before the update we'll need to revert both the catalog and assets service to the point in time copy in the `VolumeSnapshot` we created. 

We'll use NetApp trident's and FSxN capabilities to restore from Snapshot in place by using the `TridentActionSnapshotRestore` CRD. For that we'll need a short downtime for our catalog and assets services.  
#### Scaledown the assts and catalog services
Scale down the number of active pods shutdown the assets service:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl scale deploy assets -n tenant0 --replicas=0
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
deployment.apps/assets scaled
:::
Check number of Pods in service is zero:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get deploy assets -n tenant0
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
assets           0/0     0            0           28h
:::
Scale down the number of active pods shutdown the catalog mysql service:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl scale statefulset catalog-mysql -n tenant0 --replicas=0
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
statefulset.apps/catalog-mysql scaled
:::
::::alert{type="info" header="VolumeAttachment deletion"}
In some cases the PVC of the statefulset doesn't release the VolumeAttachment from the node. Please verify it does by using `kubectl get volumeattachment -n tenant0`. If the attachment of the relevant PV is there use this command to remove it `kubectl delete volumeattachment <attachment-name> -n tenant0`
::::
Check number of Pods in service is zero:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get statefulset catalog-mysql -n tenant0
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
NAME            READY   AGE
catalog-mysql   0/0     28h
:::

#### In-place restore from `VolumeSnapshot`
Run restore in place using `snap-restore.yaml`
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl create -f ../labs/lab2/snap-restore.yaml
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
tridentactionsnapshotrestore.trident.netapp.io/assets-share created
tridentactionsnapshotrestore.trident.netapp.io/data-catalog-mysql-0 created
:::

#### Restart the assets and catalog services
Restart the assets pods:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl scale deploy assets -n tenant0 --replicas=1
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
deployment.apps/assets scaled
:::

Restart the catalog mysql db pods:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl scale statefulset catalog-mysql -n tenant0 --replicas=1
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
statefulset.apps/catalog-mysql scaled
:::

Now that we recovered our catalog, we'll check our tenant's data and verify everything was restored.