# Lab 1 - Implement multi-tenancy using FSx for ONTAP capabilities
* ### *Experience the different ways to isolate tenants and data on SVMs and volumes.* 
* ### *Demonstrate the different ways to isolate tenants working with Labels and Selectors.*
* ### *Mapping deployments to dedicated resources(Isolating backends and EKS nodegroups).*  

## Lab setup ##
* A single FSxN file system 

* EKS cluster with 2 node groups, each in a different ip range, trident installed, defaut backend and storage class for Tenant0. , 
  
* Pod with a linux OS for SSH for FSxN ONTAP cli

* Sample application on tenant0 pre-configured with volumes on FSxn isloated to work with the first NodeGroup 

&nbsp;
>***validate Tenant0 namespace***   

```
%kubectl get ns tenant0 

	*** out put should look like this 
		NAME      STATUS   AGE  
		tenant0   Active   68m
```

&nbsp;
>***Validate sample app is running***
```
%kubectl get pods -n tenant0

	**** output should look like this 
		NAME                              READY   STATUS    RESTARTS      AGE
		assets-6694b7ccff-vxh86           1/1     Running   0             51m
		carts-8c454c85c-6dlq5             1/1     Running   2 (50m ago)   51m
		carts-dynamodb-57dc7d97d5-psbb2   1/1     Running   0             51m
		catalog-6ffdd78f77-wfx2r          1/1     Running   5 (50m ago)   51m
		catalog-mysql-0                   1/1     Running   1 (50m ago)   51m
		checkout-8b8548dd8-j7hj7          1/1     Running   0             51m
		checkout-redis-78f4d66577-ntkb7   1/1     Running   0             51m
		orders-6574497d84-slcmw           1/1     Running   2 (50m ago)   51m
		orders-mysql-0                    1/1     Running   0             51m
		orders-rabbitmq-0                 1/1     Running   0             51m
		ui-774d676c59-j9fxt               1/1     Running   0             51m	
```

&nbsp;
>***Display default EKS nodegroup names and custom labels created during intial setup***


* kubectl get nodes -o custom-columns=\\\
'NODE_NAME:.metadata.name,IP:.status.addresses[?(@.type=="InternalIP")].address,\\\
EKS_NODE_GROUP_DEFAULT_LABEL:.metadata.labels.eks\\.amazonaws\\.com/nodegroup,\\\
EKS_CUSTOM_LABEL:.metadata.labels.TenantName'


```
NODE_NAME                    IP           EKS_NODE_GROUP_DEFAULT_LABEL                      EKS_CUSTOM_LABEL
ip-10-0-1-236.ec2.internal   10.0.1.236   eks-saas-node-group-20240926065401938000000034    nodeGroupTenant0
ip-10-0-1-99.ec2.internal    10.0.1.99    eks-saas-node-group-20240926065401938000000034    nodeGroupTenant0
ip-10-0-2-195.ec2.internal   10.0.2.195   eks-saas-node-group2-20240926065401938000000032   nodeGroupTenant1
ip-10-0-2-205.ec2.internal   10.0.2.205   eks-saas-node-group2-20240926065401938000000032   nodeGroupTenant1
```


&nbsp;
# Task 1 - Objectives
___

### *Create a new sample application within the same FSxN file system and (SVM) Storage Virtual Machine, using different volume(s).  The new application will be deployed on a new tenanat, seporate eks nodeGroup and volumes for isolation*  

* ### Task objective: Show how dedicated volumes can be used for multitenant with tenant isolation
  * step 1 - create lab1 tenant1 namespace 
  * step 2 - create lab1 backends nas / san
  * step 3 - Create lab1 storageclass nas / san 
  * step 4 - deploy loadbalancer and sample application on tenant1 

&nbsp;
## **Step 1:** Create `namespace`
### *In this step you are going to create a new tenant namespace* 

>### *Create a new EKS namespace for Tenant1.*
```
	kubectl create namespace tenant1 
	  	namespace/tenant1 created
		
	kubectl get ns tenant1
		NAME      STATUS   AGE
		tenant1   Active   22s
```

&nbsp;
## **Step 2:** Create `backends`
### *Create new san and nas Trident backends on the default svm.  Both backens will be created with a FSxN export policy isolated to EKS nodegroup2 for Tenant1.*

* Export policy to isolate tenant1 to nodegroup 2 
* backend and storage labels for resource mapping
	* backend identity labels __"nodegroup=nodeGroup2" "lab=lab1"__ 
	* unique backend name with suffix __"-lab1"__ 
	* Export policy for NFS isolation
	* storage labels to map storage class to backends  
  

&nbsp;
> ### *Create backends with export policy isolating connectivity from tenant1 to the second nodegroup* 
* using the preconfigured backends.yaml file with nfs export policy and storage labels

```
kubectl apply -f ../labs/lab1/backends.yaml 
	tridentbackendconfig.trident.netapp.io/backend-tbc-ontap-nas-lab1 created
	tridentbackendconfig.trident.netapp.io/backend-tbc-ontap-san-lab1 created
```
```yaml
------- EXAMPLE FILE OUTPUT -------
### cat ../labs/lab1/backends.yaml ###
---
apiVersion: trident.netapp.io/v1
kind: TridentBackendConfig
metadata:
  name: backend-tbc-ontap-nas-lab1
  namespace: trident
  labels:
    nodegroup: nodeGroup2  ### k8 object identity labels
    lab: lab1     		   ### k8 object identity labels
spec:
  version: 1
  storageDriverName: ontap-nas
  backendName: tbc-ontap-nas-lab1
  svm: ekssvm           
  aws:
   fsxFilesystemID: fs-09xxxxxxxxxxf03
  credentials:
    name: arn:aws:secretsmanager:us-east-1:75xxxxxxxxxx48:secret:fsxn-password-secret-H8sVhtM7-uukRFc
    type: awsarn
  autoExportCIDRs:
  - 10.0.2.0/24   ### Export policy isolation 
  autoExportPolicy: true
  storage:  #### storage labels for storage class mapping 
  - labels:
      department: lab1 ### <<<<used by storageClass Selector>>>>
---
apiVersion: trident.netapp.io/v1
kind: TridentBackendConfig
metadata:
  name: backend-tbc-ontap-san-lab1
  namespace: trident
  labels:
    nodegroup: nodeGroup2  #### k8 object identity labels 
    lab: lab1			   #### k8 object identity labels
spec:
  version: 1
  storageDriverName: ontap-san
  backendName: tbc-ontap-san-lab1
  svm: ekssvm 
  aws:
    fsxFilesystemID: fs-091xxxxxxxxxxxxx03
  credentials:
    name: arn:aws:secretsmanager:us-east-1:759xxxxxxx48:secret:fsxn-password-secret-H8sVhtM7-uukRFc 
    type: awsarn
  storage: #### storage labels for storage class mapping
  - labels:
      department: lab1 ### <<<<used by storageClass Selector>>>>
```

&nbsp;
## **Step 3:** Create `Storage Class`
### *In this step we are going to Create StorageClass for the backends*
* The storage class will be used by the sample application deployed in tenant1 and will consume the backends that have been configured with the NodeGroup2 export policy. 
	* this 

&nbsp;
> ### *Create two new storage classes for lab1 backends*
```
kubectl apply -f ../labs/lab1/storageclass.yaml 
	storageclass.storage.k8s.io/trident-csi-nas-lab1 created
	storageclass.storage.k8s.io/trident-csi-san-lab1 created

```

```yaml
------- EXAMPLE FILE OUTPUT -------
### cat ../labs/lab1/storageclass.yaml ###

---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: trident-csi-nas-lab1
provisioner: csi.trident.netapp.io
parameters:
  backendType: "ontap-nas"
  fsType: "ext4"
  selector: "department=lab1"  ###<<mapped to backend storage label>>
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
  selector: "department=lab1"  ###<<mapped to backend storage label>>
allowVolumeExpansion: True
reclaimPolicy: Delete

```


&nbsp;
## **Step 4:** Create `loadbalancer` and `sample application` 
### *In this step we are going to Deploy new sample application in tenant1 that is mapped to new backends*
* Deploy UI loadbalancer service on tenant1
* Deploy Sample application 
* Display output of sample app mapped to new isolated backends


&nbsp;
>Deploy the UI `loadbalancer` service for the sample application 
```
kubectl apply -f ../labs/lab1/svc.yaml -n tenant1


------- example output  -----------
kubectl get svc -n tenant1                       
NAME   TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)        AGE
ui     LoadBalancer   172.xx.xx.xx   saas-fsxn-workshop-ui-lab1-fb322b8c0417312f.elb.us-east-1.amazonaws.com   80:32221/TCP   17s

```


&nbsp;
>Deploy the `sample app` on tenant1. validate it is mapped to the new backends and configured with the isolated export policy on nodegroup2 

```
% kubectl apply -f ../labs/lab1/sample.yaml -n tenant1

#### Example output for tenanat1 sample app 
% kubectl get pods -n tenant1 
NAME                              READY   STATUS    RESTARTS      AGE
assets-558748b8b-7ln2b            1/1     Running   0             86m
carts-9587bb8db-hw2gr             1/1     Running   0             86m
carts-dynamodb-7f5c4b57d8-wjgjn   1/1     Running   0             86m
catalog-596946f4bb-nhnc8          1/1     Running   4 (85m ago)   86m
catalog-mysql-0                   1/1     Running   0             86m
checkout-544cbc54bc-f6j7v         1/1     Running   0             86m
checkout-redis-5698478644-gg9wn   1/1     Running   0             86m
orders-9756b8cf-fpn5d             1/1     Running   2 (85m ago)   86m
orders-mysql-0                    1/1     Running   0             86m
orders-rabbitmq-0                 1/1     Running   0             86m
ui-d78785d7b-6xdgg                1/1     Running   0             86m
```


&nbsp;
>Display output of tenanat1 persistant volume mapping with lab1 `isolated backend`

```shell
### shows application and persistant volume mapping ###
kubectl get pv  ## Comlete output with all columns 

### Short list of selected columns from kubectl get pv 
kubectl get pv -o=custom-columns=\
'TENANT:.spec.claimRef.namespace,\
NAME:.spec.claimRef.name,\
STORAGECLASS:.spec.storageClassName'

### Example output of pvc claim and storageclass ### 
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                            STORAGECLASS          
pvc-13a70962-0946-440b-9625-90074c3b9b8d   30Gi       RWO            Delete           Bound    tenant0/data-catalog-mysql-0     trident-csi-san       
pvc-435f8dda-f526-46fa-9b6c-16d52799909c   5Gi        RWX            Delete           Bound    tenant0/assets-share             trident-csi-nas       
pvc-ccb4dee4-397f-4e15-9b41-8f387cf9c79a   30Gi       RWO            Delete           Bound    tenant0/data-orders-mysql-0      trident-csi-san       
pvc-f8d10650-eeac-409f-9fb7-a4c2d7fa72ee   30Gi       RWO            Delete           Bound    tenant0/data-orders-rabbitmq-0   trident-csi-san       
pvc-3f763e48-1722-4d25-9b97-5bfb4dc1af42   30Gi       RWO            Delete           Bound    tenant1/data-orders-rabbitmq-0   trident-csi-san-lab1  
pvc-41650f68-4a32-40b6-b269-b2da4e4c88f3   5Gi        RWX            Delete           Bound    tenant1/assets-share             trident-csi-nas-lab1  
pvc-5751ee55-89ff-49b9-8c55-b1346f253626   30Gi       RWO            Delete           Bound    tenant1/data-catalog-mysql-0     trident-csi-san-lab1  
pvc-d308aa04-c3ba-446e-ae3f-ed6d11a73969   30Gi       RWO            Delete           Bound    tenant1/data-orders-mysql-0      trident-csi-san-lab1  
```

&nbsp;
## **Step 5:** Login to application and `Change database`
### On this step you are going to login to the new tenant1 application, make changes to the database and compare the the two applications between tenant0 and tenant1.
* Login to the tenant1 application 
* Change the application database 
* Compare tenant0 and tenant1 applications 

&nbsp;
> # Login to the tenant1 application MySQL server:


```bash
### connect to mySQL 
kubectl exec -it catalog-mysql-0 -n tenant0 -- mysql -u root -pmy-secret-pw

### Expected output ###

mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 5.7.44 MySQL Community Server (GPL)

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```


&nbsp;
> # Change application database 
* Add a new product to the catalog database:
```shell

### sql command to use catalog 
mysql> use catalog
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed


### List all products in catalog database 
mysql> select * from product;
+--------------------------------------+--------------------+------------------------------------------+-------+-------+----------------------------+
| product_id                           | name               | description                              | price | count | image_url                  |
+--------------------------------------+--------------------+------------------------------------------+-------+-------+----------------------------+
| 510a0d7e-8e83-4193-b483-e27e09ddc34d | Gentleman          | Touch of class for a bargain.            |   795 |    51 | /assets/gentleman.jpg      |
| 6d62d909-f957-430e-8689-b5129c0bb75e | Pocket Watch       | Properly dapper.                         |   385 |    33 | /assets/pocket_watch.jpg   |
| 808a2de1-1aaa-4c25-a9b9-6612e8f29a38 | Chronograf Classic | Spend that IPO money                     |  5100 |     9 | /assets/chrono_classic.jpg |
| a0a4f044-b040-410d-8ead-4de0446aec7e | Wood Watch         | Looks like a tree                        |    50 |   115 | /assets/wood_watch.jpg     |
| ee3715be-b4ba-11ea-b3de-0242ac130004 | Smart 3.0          | Can tell you what you want for breakfast |   650 |     9 | /assets/smart_1.jpg        |
| f4ebd070-b4ba-11ea-b3de-0242ac130004 | FitnessX           | Touch of class for a bargain.            |   180 |    76 | /assets/smart_2.jpg        |
+--------------------------------------+--------------------+------------------------------------------+-------+-------+----------------------------+
6 rows in set (0.00 sec)


### Add cockoo clock to catalog 
mysql> INSERT INTO product VALUES ("f4ebd070-b4ba-11ea-b3de-4de0446aec7e", "Cuckoo clock", "Great for bird lovers.",  550, 3, "/assets/cuckoo.jpg");
Query OK, 1 row affected (0.00 sec)

### Insert product tag for cockoo clock 
mysql> INSERT INTO product_tag VALUES ("f4ebd070-b4ba-11ea-b3de-4de0446aec7e", "1");
Query OK, 1 row affected (0.00 sec)

### Updated list with new item "Cuckoo clock" 
mysql> select * from product;
+--------------------------------------+--------------------+------------------------------------------+-------+-------+----------------------------+
| product_id                           | name               | description                              | price | count | image_url                  |
+--------------------------------------+--------------------+------------------------------------------+-------+-------+----------------------------+
| 510a0d7e-8e83-4193-b483-e27e09ddc34d | Gentleman          | Touch of class for a bargain.            |   795 |    51 | /assets/gentleman.jpg      |
| 6d62d909-f957-430e-8689-b5129c0bb75e | Pocket Watch       | Properly dapper.                         |   385 |    33 | /assets/pocket_watch.jpg   |
| 808a2de1-1aaa-4c25-a9b9-6612e8f29a38 | Chronograf Classic | Spend that IPO money                     |  5100 |     9 | /assets/chrono_classic.jpg |
| a0a4f044-b040-410d-8ead-4de0446aec7e | Wood Watch         | Looks like a tree                        |    50 |   115 | /assets/wood_watch.jpg     |
| ee3715be-b4ba-11ea-b3de-0242ac130004 | Smart 3.0          | Can tell you what you want for breakfast |   650 |     9 | /assets/smart_1.jpg        |
| f4ebd070-b4ba-11ea-b3de-0242ac130004 | FitnessX           | Touch of class for a bargain.            |   180 |    76 | /assets/smart_2.jpg        |
| f4ebd070-b4ba-11ea-b3de-4de0446aec7e | Cuckoo clock       | Great for bird lovers.                   |   550 |     3 | /assets/cuckoo.jpg         |
+--------------------------------------+--------------------+------------------------------------------+-------+-------+----------------------------+
7 rows in set (0.00 sec)

### exit database 
mysql> exit
Bye
```
```shell
### Add new product image to the assets store:

kubectl exec --stdin deployment/assets -n tenant1 -- bash -c 'curl https://upload.wikimedia.org/wikipedia/commons/f/fc/Du200613.png -o /usr/share/nginx/html/assets/cuckoo.jpg'

### Expected output:

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  116k  100  116k    0     0   887k      0 --:--:-- --:--:-- --:--:--  890k

kubectl exec -n tenant0 --stdin deployment/assets -- bash -c 'ls /usr/share/nginx/html/assets'

chrono_classic.jpg
cuckoo.jpg
gentleman.jpg
pocket_watch.jpg
smart_1.jpg
smart_2.jpg
wood_watch.jpg
```


&nbsp;
* Log in to tenant1 web ui and check the store catalog. You should now see 7 items in the catalog. 

![step0-webui](../lab2/images/lab2-step4-0.png)

* Select the new item in the catalog and check it out:

![step0-webui](../lab2/images/lab2-step4-1.png)


&nbsp;
> #  Compare tenant0 and tenant1 web catalogs 
```shell 

### you can use the External public name to open the catalog for each tenant and compare.
--------------------- 
  kubectl get svc ui -n tenant0 

NAME   TYPE           CLUSTER-IP       EXTERNAL-IP                                                          PORT(S)        AGE
ui     LoadBalancer   172.20.183.113   saas-fsxn-workshop-ui-ac96aa73f4863672.elb.us-east-1.amazonaws.com   80:32710/TCP   84m
---------------------
  kubectl get svc ui -n tenant1

NAME   TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)        AGE
ui     LoadBalancer   172.20.72.109   saas-fsxn-workshop-ui-lab1-26536922e0863bbc.elb.us-east-1.amazonaws.com   80:31139/TCP   51m
moshes@moshes-mac-0 lab1 % 

```


&nbsp;
## **Step 6#:** - step `headline`
### *next step descri*
* bullets here 



&nbsp;
> action 
>


```copy
copy my code 

```

&nbsp;
## **Step 7#:** - step `headline`
### *next step descri*
* bullets here 



&nbsp;
> action 
>


```copy
copy my code 

```
&nbsp;
## **Step 8#:** - step `headline`
### *next step descri*
* bullets here 



&nbsp;
> action 
>


```copy
copy my code 

```
