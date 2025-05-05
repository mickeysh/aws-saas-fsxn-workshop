---
apiVersion: trident.netapp.io/v1
kind: TridentBackendConfig
metadata:
  name: backend-tbc-ontap-nas-lab1-svm
  namespace: trident
  labels:
    lab: lab1
spec:
  version: 1
  storageDriverName: ontap-nas
  backendName: tbc-ontap-nas-lab1-svm
  svm: ${fs_svm}
  aws:
    fsxFilesystemID: ${fs_id}
  credentials:
    name: ${secret_arn}
    type: awsarn
  storage:
  - labels:
      department: lab1
---
apiVersion: trident.netapp.io/v1
kind: TridentBackendConfig
metadata:
  name: backend-tbc-ontap-san-lab1-svm
  namespace: trident
  labels:
    lab: lab1
spec:
  version: 1
  storageDriverName: ontap-san
  backendName: tbc-ontap-san-lab1-svm
  svm: ${fs_svm}
  aws:
    fsxFilesystemID: ${fs_id}
  credentials:
    name: ${secret_arn}
    type: awsarn
  storage:
  - labels:
      department: lab1