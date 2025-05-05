---
chapter: true
title: Workshop Architecture
weight: 41
---
For the purposes of this workshop, we will use the *US West* *(Oregon)* regions. 

### Infrasturcture Architecture
The diagram below shows the high-level architecture of the configuration you will build in this workshop.

![][def]

### Software Architecture
We will also use the AWS [retail store sample application](https://github.com/aws-containers/retail-store-sample-app) as our basic tenant software stack.
This application is built from micro-services and backed by several stateful services. In total they consume 4 [Persistent Volume Claims](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) (PVC) for each stack:
- Assets - Serves static assets like images related to the product catalog - Requires RWX volume like NFS
- Orders - Receive and process customer orders backed by MySQL DB and RabitMQ - Requires 2 RWO block storage volumes
- Catalog - Product listings and details backed by MySQL DB - Requires RWO block storage volume

![sample-app](/static/sample-app-architecture.png)

The AWS resources needed to run these labs include:

+ Amazon FSx for NetApp ONTAP as out persistent storage layer. [See documentation](https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/what-is-fsx-ontap.html).
+ Amazon EKS to run our SaaS. [See Documentation](https://docs.aws.amazon.com/eks/).
+ Amazon FSx for NetApp ONTAP CSI driver. [See documentation](https://docs.aws.amazon.com/eks/latest/userguide/fsx-ontap.html)

[def]: /static/architecture.png
