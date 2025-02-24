## Create a Backup snapshot to the catalog database
We will start by creating the snapshot backup of the catalog service within out sample application. For that we'll need to create a `VolumeSnapshotClass` and a `VolumeSnapshot` to both the assets and catalog serivces. 
> [!IMPORTANT]
> This lab is focused on our `eks-primary` cluster so make sure you set the context for kubectl to use that cluster by using the following command:
> ```shell
> kubectl config use-context eks-primary
> ```

### Step 1 - Create `VolumeSnapshotClass` for `tenant0`.
Use [volume-snapshot-class.yaml](volume-snapshot-class.yaml) manifset to create a VolumeSnapshotClass:
```
kubectl create -n tenant0 -f ../labs/lab2/volume-snapshot-class.yaml
```
Expected output:
`volumesnapshotclass.snapshot.storage.k8s.io/fsx-snapclass created`

### Step 2 - Create `VolumeSnapshot` on both the catalog DB volume and the assets images volume. 
Use [volume-snapshot.yaml](volume-snapshot.yaml) to create the snapshots:
```
kubectl create -n tenant0 -f ../labs/lab2/volume-snapshot.yaml
```
Expected output:
`volumesnapshot.snapshot.storage.k8s.io/data-catalog-mysql-0-snap created
volumesnapshot.snapshot.storage.k8s.io/assets-share created`

### Step 3 - Run the followin to verify the `VolumeSnapshot`s:
```
kubectl get vs -n tenant0
```
Expected output:
```
NAME                        READYTOUSE   SOURCEPVC              SOURCESNAPSHOTCONTENT   RESTORESIZE   SNAPSHOTCLASS   SNAPSHOTCONTENT                                    CREATIONTIME   AGE
assets-share                true         assets-share                                   324Ki         fsx-snapclass   snapcontent-5417f976-7504-49bc-a204-70dc63cd3d5f   29s            30s
data-catalog-mysql-0-snap   true         data-catalog-mysql-0                           30Gi          fsx-snapclass   snapcontent-48a6e942-b2fd-4fca-aa75-4c4d69e91f0e   30s            30s
```