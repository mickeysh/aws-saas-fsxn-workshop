# Task 1 - Objectives
Create a new sample application within the same FSxN file system and (SVM) Storage Virtual Machine, using different volume(s).  The new application will be deployed on a new tenant, seporate eks nodeGroup and volumes for isolation  

* ### Task objective: Show how dedicated volumes can be used for multitenant with tenant isolation
  * Step 1 - Create lab1 tenant1 namespace 
  * Step 2 - Create lab1 backends nas/san
  * Step 3 - Create lab1 storageclass nas/san 
  * Step 4 - deploy loadbalancer and sample application on tenant1 

### Step 1 - Create new tenant namespace

In this step you are going to create a new tenant namespace

```shell
kubectl create namespace tenant1 
namespace/tenant1 created
```
Expected output:
```shell
kubectl get ns tenant1
NAME      STATUS   AGE
tenant1   Active   22s
```