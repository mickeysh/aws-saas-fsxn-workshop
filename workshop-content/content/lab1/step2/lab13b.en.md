---
title : "Step 2 - Create Trident CSI storage backends (SVM Alternative)"
weight : 65
---
Create new block storage and file storage Trident CSI backends on a seperate svm `ekssvmt2` for our new tenant.

::::alert{type="info" header="SVM - Storage Backend"}
To reference the spesific Trident Backend config from the Kubernetes storage class we will need to label the backend resource. 
Examine the following backendsvm.yaml sample code.
- To map between different StorageClasses and Trident Backend Configs we'll create a storage label on the backend named `department` with the value of `lab1`.
:::code{showCopyAction=false showLineNumbers=false language=yaml}
apiVersion: trident.netapp.io/v1
kind: TridentBackendConfig
metadata:
  name: backend-tbc-ontap-nas-lab1-svm
  namespace: trident
  labels:
    lab: lab1     		   ### k8 object identity labels
spec:
  version: 1
  storageDriverName: ontap-nas
  backendName: tbc-ontap-nas-lab1-svm
  svm: ekssvmt2           
  aws:
   fsxFilesystemID: fs-09xxxxxxxxxxf03
  credentials:
    name: arn:aws:secretsmanager:us-east-1:75xxxxxxxxxx48:secret:fsxn-password-secret-H8sVhtM7-uukRFc
    type: awsarn
  storage:  #### storage labels for storage class mapping 
  - labels:
      department: lab1 ### <<<<used by storageClass Selector>>>> 
::: 
::::
Create backends with a seperate SVM to isolate connectivity from tenant1 to this SVM using the preconfigured `backendsvm.yaml` file with storage labels.

:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl apply -f ../labs/lab1/backendsvm.yaml 
:::

Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
tridentbackendconfig.trident.netapp.io/backend-tbc-ontap-nas-lab1-svm created
tridentbackendconfig.trident.netapp.io/backend-tbc-ontap-san-lab1-svm created
:::

### Create Storage Class
In this step we are going to Create StorageClass for the backends

::::alert{type="info" header="SVM - storageClass"}
The storage class will be used by the sample application deployed in tenant1 and will consume the backends that have been configured in the previous step. We'll use the `selector` parameter to point the the `department=lab1` storage label for out Trident backend.
:::code{showCopyAction=false showLineNumbers=false language=yaml}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: trident-csi-nas-lab1
provisioner: csi.trident.netapp.io
parameters:
  backendType: "ontap-nas"
  fsType: "ext4"
  selector: "department=lab1"  ###<<mapped to backend storage label>>
allowVolumeExpansion: True
reclaimPolicy: Delete
:::
::::

Create two new storage classes for lab1 backends using `storageclass.yaml` sample file.
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl apply -f ../labs/lab1/storageclass.yaml
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
    storageclass.storage.k8s.io/trident-csi-nas-lab1 created
    storageclass.storage.k8s.io/trident-csi-san-lab1 created
:::

Now that you create the storageClass mapping for both tenants, please continue to the next section where we'll deploy our net tenant's application.