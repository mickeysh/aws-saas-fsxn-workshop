apiVersion: trident.netapp.io/v1
kind: TridentBackendConfig
metadata:
  name: backend-tbc-ontap-san
  namespace: trident
spec:
  version: 1
  storageDriverName: ontap-san
  backendName: tbc-ontap-san
  svm: ${fs_svm}
  aws:
    fsxFilesystemID: ${fs_id}
  credentials:
    name: ${secret_arn}
    type: awsarn