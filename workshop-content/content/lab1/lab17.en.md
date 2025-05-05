---
title : "Summary"
weight : 69
---
In this lab we deployed a new tenant with the entire sample app software stack using the same Amazon FSx for ONTAP file-system while keeping the tenant's data volumes isolated using FSxN Export Policy features. We created a storage backend on the CSI driver dedicated to the network subnet of our new tenent and limited access to nodes running only on this subnet. 

In the next lab we'll exolore some data protection features that can be used to backup and restore a single file, volume or tenant.