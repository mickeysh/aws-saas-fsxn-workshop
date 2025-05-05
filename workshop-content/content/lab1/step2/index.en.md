---
title : "Step 2 - Create Trident CSI storage backends"
weight : 63
---

For the next step we have two seperate alternatives to create storage tenant isolcation for the workshop:
1. [ONTAP Export Policy](/lab1/step2/lab13a) - Isolate access from EKS nodeGroups to the storage access limiting data access mounts to only the tenant's nodeGroups.
2. [Storage Virtual Machine (SVM)](/lab1/step2/lab13b) - Isolate PVC creation and access to a seperate isolated storage service within the same FSxN file-system.

Choose either option and create the storage backend and EKS storageClass. 