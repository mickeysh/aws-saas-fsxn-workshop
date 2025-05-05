---
title : "Lab 3 - Remote Disaster Recovery"
weight : 80
---
Meet stricter SLAs and disaster recovery requirements by replicating data across multiple AWS regions. 

In this lab we will create a DR mirror relationship between the `eks primary` and the `eks dr` clusters. We will also practice a DR event and switch out production application and data state to the DR. 

This is a general architecture of the infrasturcture and application componenets for this lab: 
![lab3-architecture](/static/snapmirror.png)