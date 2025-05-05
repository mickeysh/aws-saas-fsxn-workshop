---
title : "Step 3 - Create loadbalancer and sample application"
weight : 66
---
In this step we are going to Deploy new sample application in tenant1 that is mapped to new backends
* Deploy UI loadbalancer service on tenant1
* Deploy Sample application 
* Display output of sample app mapped to new isolated backends

### Deploy UI LoadBalancer
Deploy the UI `loadbalancer` service for the sample application:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl apply -f ../labs/lab1/svc_ldb.yaml -n tenant1
::::

Check the UI `loadbalancer` service was created successfully
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get svc -n tenant1
:::

Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
NAME   TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)        AGE
ui     LoadBalancer   172.xx.xx.xx   saas-fsxn-workshop-ui-lab1-fb322b8c0417312f.elb.us-east-1.amazonaws.com   80:32221/TCP   17s
:::

### Deploy tenant1 sample application
Deploy the `sample app` on tenant1. validate it is mapped to the new backends and configured with the isolated export policy on nodegroup2 
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl apply -f ../labs/lab1/sample.yaml -n tenant1
:::
Check sample app pods are running on tenant1:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get pods -n tenant1 
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
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
:::

Display output of tenanat1 persistant volume mapping with lab1 isolated backend

Shows application and persistant volume mapping with complete output
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get pv
:::
Or display selected relevant columns
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get pv -o=custom-columns=\
'TENANT:.spec.claimRef.namespace,\
NAME:.spec.claimRef.name,\
STORAGECLASS:.spec.storageClassName'
:::

Example output of pvc claim and storageclass:
:::code{showCopyAction=false showLineNumbers=false language=shell}
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                            STORAGECLASS          
pvc-13a70962-0946-440b-9625-90074c3b9b8d   30Gi       RWO            Delete           Bound    tenant0/data-catalog-mysql-0     trident-csi-san       
pvc-435f8dda-f526-46fa-9b6c-16d52799909c   5Gi        RWX            Delete           Bound    tenant0/assets-share             trident-csi-nas       
pvc-ccb4dee4-397f-4e15-9b41-8f387cf9c79a   30Gi       RWO            Delete           Bound    tenant0/data-orders-mysql-0      trident-csi-san       
pvc-f8d10650-eeac-409f-9fb7-a4c2d7fa72ee   30Gi       RWO            Delete           Bound    tenant0/data-orders-rabbitmq-0   trident-csi-san       
pvc-3f763e48-1722-4d25-9b97-5bfb4dc1af42   30Gi       RWO            Delete           Bound    tenant1/data-orders-rabbitmq-0   trident-csi-san-lab1  
pvc-41650f68-4a32-40b6-b269-b2da4e4c88f3   5Gi        RWX            Delete           Bound    tenant1/assets-share             trident-csi-nas-lab1  
pvc-5751ee55-89ff-49b9-8c55-b1346f253626   30Gi       RWO            Delete           Bound    tenant1/data-catalog-mysql-0     trident-csi-san-lab1  
pvc-d308aa04-c3ba-446e-ae3f-ed6d11a73969   30Gi       RWO            Delete           Bound    tenant1/data-orders-mysql-0      trident-csi-san-lab1  
:::

Now lets create some updated on our new tenent's application data/storage.