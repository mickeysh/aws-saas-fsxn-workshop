---
title : "Step 1: Create peering between the production and DR FSxN filesystems"
weight : 81
---
In this part of the lab we will create a [cluster peering relationship](https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/migrating-fsx-ontap-snapmirror.html#cluster-peering) between the `eks-primary` and the `eks-dr` clusters and [SVM peering relationship](https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/migrating-fsx-ontap-snapmirror.html#svm-peering) between relevant SVMs on each cluster (`ekssvm` and `ekssvm2` respectively). This is required once per file-system pair and enables creating the mirror relationships for volumes these file-systems.  

For the next step we have two seperate alternatives to create the peering relationships:
1. [Manual setup through ONTAP CLI](/lab3/step1/lab30)
2. [Automated using K8s Job](/lab3/step1/lab31)

Choose either option and create the cluster and SVM peering.