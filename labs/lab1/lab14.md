### Step 2 - Create Trident CSI storage backends

Create new block storage and file storage Trident CSI backends on the default svm. Both backedns will be created with a FSxN export policy isolated to EKS nodegroup2 for Tenant1.

> [!IMPORTANT]
> To reference the spesific Trident Backend config from the Kubernetes storage class we will need to label the backend resource. 
> Examine the following backend.yaml sample code.
> - To create storage nodeGroup isolation we'll use the FSx ONTAP export policy setting `autoExportCIDRs` and limit that to `nodeGroupTenant1` nodes.
> - To map between different StorageClasses and Trident Backend Configs we'll create a storage label on the backend named `department` with the value of `lab1`.
> ```yaml
>---
>apiVersion: trident.netapp.io/v1
>kind: TridentBackendConfig
>metadata:
>  name: backend-tbc-ontap-nas-lab1
>  namespace: trident
>  labels:
>    nodegroup: nodeGroup2  ### k8 object identity labels
>    lab: lab1     		   ### k8 object identity labels
>spec:
>  version: 1
>  storageDriverName: ontap-nas
>  backendName: tbc-ontap-nas-lab1
>  svm: ekssvm           
>  aws:
>   fsxFilesystemID: fs-09xxxxxxxxxxf03
>  credentials:
>    name: arn:aws:secretsmanager:us-east-1:75xxxxxxxxxx48:secret:fsxn-password-secret-H8sVhtM7-uukRFc
>    type: awsarn
>  autoExportCIDRs:
>  - 10.0.2.0/24   ### Export policy isolation 
>  autoExportPolicy: true
>  storage:  #### storage labels for storage class mapping 
>  - labels:
>      department: lab1 ### <<<<used by storageClass Selector>>>> 
>``` 

Create backends with export policy isolating connectivity from tenant1 to the second nodegroup using the preconfigured [backends.yaml](backends.yaml) file with nfs export policy and storage labels.

```bash
kubectl apply -f ../labs/lab1/backends.yaml 
```

Expected output:
```bash
tridentbackendconfig.trident.netapp.io/backend-tbc-ontap-nas-lab1 created
tridentbackendconfig.trident.netapp.io/backend-tbc-ontap-san-lab1 created
```

### Step 3 - Create Storage Class
In this step we are going to Create StorageClass for the backends

> [!IMPORTANT]
The storage class will be used by the sample application deployed in tenant1 and will consume the backends that have been configured with the NodeGroup2 export policy. We'll use the `selector` parameter to point the the `department=lab1` storage label for out Trident backend.
>```yaml
>---
>apiVersion: storage.k8s.io/v1
>kind: StorageClass
>metadata:
>  name: trident-csi-nas-lab1
>provisioner: csi.trident.netapp.io
>parameters:
>  backendType: "ontap-nas"
>  fsType: "ext4"
>  selector: "department=lab1"  ###<<mapped to backend storage label>>
>allowVolumeExpansion: True
>reclaimPolicy: Delete
>```
Create two new storage classes for lab1 backends using [storageclass.yaml](storageclass.yaml) sample file.
```bash
kubectl apply -f ../labs/lab1/storageclass.yaml
```
Expected output:
```bash 
	storageclass.storage.k8s.io/trident-csi-nas-lab1 created
	storageclass.storage.k8s.io/trident-csi-san-lab1 created

```

