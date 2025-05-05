---
title : "Summary"
weight : 87
---
In this lab we learned how to use Amazon FSx for ONTAP Snapmirror replication to enable easy remote DR capabilities for stateful application running in Amazon EKS. Using the TridenrMirrorRalationships (TMR) Custom Resource, which is part of the NetApp Trident CSI driver, we were easly able and replicate PVCs between 2 remote EKS clusters and automate the failover of a single tenant within our EKS SaaS environment. These capabilities provides better SLAs to our services by keeping both Recovery Point Pobjectives (RPO) and Recovery Time Objective (RTO) short. 