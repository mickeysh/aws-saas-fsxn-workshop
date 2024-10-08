---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: trident-csi-nas-lab1
provisioner: csi.trident.netapp.io
parameters:
  backendType: "ontap-nas"
  fsType: "ext4"
  selector: "department=lab1"
allowVolumeExpansion: True
reclaimPolicy: Delete
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: trident-csi-san-lab1
provisioner: csi.trident.netapp.io
parameters:
  backendType: "ontap-san"
  fsType: "ext4"
  selector: "department=lab1"
allowVolumeExpansion: True
reclaimPolicy: Delete
