---
title : "Summary"
weight : 77
---
In this lab we used the Amazon FSx for ONTAP Snapshot cababilities together with NetApp Trident CSI features to restore a tenant's catalog service data (both the mysql and NFS share) to a point in time. The unique Snapshot capabilites integrated into EKS using CSI provides easy access and automation and the ability to handle single tenant (or even a single service within a tenant) issues. The `TridentActionSnapshotRestore` has the unique capabilities to restore a point in time Snapshot in place, this reduces RTO and downtime during recovery senarios. 

In the next lab we'll exolore the remote disaster recovery features of Amazon FSx for ONTAP that when integrated with EKS can be used to replicate and recover a single tenant or an entire cluster stateful resources into a remote cluster. 