---
apiVersion: trident.netapp.io/v1
kind: TridentBackendConfig
metadata:
  name: backend-tbc-ontap-nas-lab1
  namespace: trident
  labels:
    nodegroup: nodeGroup2
    lab: lab1
spec:
  version: 1
  storageDriverName: ontap-nas
  backendName: tbc-ontap-nas-lab1
  svm: ${fs_svm}		 
  aws:
   fsxFilesystemID: ${fs_id} 	  
  credentials:
    name: ${secret_arn}  	  
    type: awsarn
  autoExportCIDRs:
  - 10.0.2.0/24
  autoExportPolicy: true
  storage:
  - labels:
      department: lab1
---
apiVersion: trident.netapp.io/v1
kind: TridentBackendConfig
metadata:
  name: backend-tbc-ontap-san-lab1
  namespace: trident
  labels:
    nodegroup: nodeGroup2
    lab: lab1
spec:
  version: 1
  storageDriverName: ontap-san
  backendName: tbc-ontap-san-lab1
  svm: ${fs_svm}                
  aws:
    fsxFilesystemID: ${fs_id}    
  credentials:
    name: ${secret_arn}        
    type: awsarn
  storage:
  - labels:
      department: lab1

