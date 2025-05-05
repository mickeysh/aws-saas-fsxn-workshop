---
title : "Lab 1 - Implement multi-tenancy using FSx for ONTAP capabilities"
weight : 60
---
# Overview 
Experience the different ways to isolate tenants and data on SVMs and volume, working with FSx for ONTAP Export Policies and EKS Labels and Selectors - Mapping deployments to dedicated resources (Isolating FSx for ONTAP storage backends and EKS nodegroups).

In this lab we'll explore 2 opetions to create storage tenant isloation with FSxN and EKS:
1. SVM Isolation - Create a storage virtual container within the file-system to isolate volumes and access
2. Volume Isolation - Create seperate volumes within the file-system and optionally restric access by network limits using ONTAP Export Policies. 

This is a general architecture of the infrasturcture and application componenets for this lab: 
![lab1-architecture](/static/lab1-step0.png)

Let's start be verifing everything required to run this lab. 