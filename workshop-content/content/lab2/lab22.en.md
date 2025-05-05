---
title : "Step 1: Create a Backup snapshot to the product catalog"
weight : 72
---

We will start by creating the snapshot backup of the catalog service within out sample application. For that we'll need to create a `VolumeSnapshotClass` and a `VolumeSnapshot` to both the assets and catalog serivces. 
::::alert{type="warning" header="EKS Cluster Context Setup"}
This lab is focused on our `eks-primary` cluster so make sure you set the context for kubectl to use that cluster by using the following command:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl config use-context eks-primary
:::
::::

#### Create `VolumeSnapshotClass` for `tenant0`.
Use `volume-snapshot-class.yaml` manifset to create a VolumeSnapshotClass:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl create -n tenant0 -f ../labs/lab2/volume-snapshot-class.yaml
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
volumesnapshotclass.snapshot.storage.k8s.io/fsx-snapclass created
:::

#### Create `VolumeSnapshot` on both the catalog DB volume and the assets images volume. 
Use `volume-snapshot.yaml` to create the snapshots:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl create -n tenant0 -f ../labs/lab2/volume-snapshot.yaml
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
volumesnapshot.snapshot.storage.k8s.io/data-catalog-mysql-0-snap created
volumesnapshot.snapshot.storage.k8s.io/assets-share created
:::

#### Run the followin to verify the `VolumeSnapshot`s:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get vs -n tenant0
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
NAME                        READYTOUSE   SOURCEPVC              SOURCESNAPSHOTCONTENT   RESTORESIZE   SNAPSHOTCLASS   SNAPSHOTCONTENT                                    CREATIONTIME   AGE
assets-share                true         assets-share                                   324Ki         fsx-snapclass   snapcontent-5417f976-7504-49bc-a204-70dc63cd3d5f   29s            30s
data-catalog-mysql-0-snap   true         data-catalog-mysql-0                           30Gi          fsx-snapclass   snapcontent-48a6e942-b2fd-4fca-aa75-4c4d69e91f0e   30s            30s
:::

Now that we backed up our tenats` data, we'll create some changed in the product catalog.