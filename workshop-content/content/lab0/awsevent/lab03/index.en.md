---
title : "Step 3: Verify Lab environment"
weight : 93
---


## Verify Lab environment

Check sample application is running on `tenant0` on the `eks-primary` cluster:
```bash
kubectl config use-context eks-primary
kubectl get pods -n tenant0
```
Expected output:
```shell
NAME                              READY   STATUS    RESTARTS        AGE
assets-6694b7ccff-gb52h           1/1     Running   0               4d19h
carts-8c454c85c-zlb8p             1/1     Running   0               4d19h
carts-dynamodb-57dc7d97d5-pxjwq   1/1     Running   0               4d19h
catalog-6ffdd78f77-hfvcf          1/1     Running   4 (4d19h ago)   4d19h
catalog-mysql-0                   1/1     Running   0               4d19h
checkout-8b8548dd8-cdg87          1/1     Running   0               4d19h
checkout-redis-78f4d66577-9gzsx   1/1     Running   0               4d19h
orders-6574497d84-d5l6c           1/1     Running   2 (4d19h ago)   4d19h
orders-mysql-0                    1/1     Running   0               4d19h
orders-rabbitmq-0                 1/1     Running   0               4d19h
ui-774d676c59-cbjqx               1/1     Running   0               4d19h
```

Check that stateful application PVCs are all allocated successfully:
```bash
kubectl get pvc -n tenant0
```
Expected output:
```shell
NAME                     STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      VOLUMEATTRIBUTESCLASS   AGE
assets-share             Bound    pvc-da599f54-b473-496c-bb45-906aefd0d898   5Gi        RWX            trident-csi-nas   <unset>                 4d19h
data-catalog-mysql-0     Bound    pvc-df3f9b0e-5fc2-42c2-9770-3806924a11e6   30Gi       RWO            trident-csi-san   <unset>                 4d19h
data-orders-mysql-0      Bound    pvc-a82e2871-a0be-4de5-bf9a-b590316ec1a3   30Gi       RWO            trident-csi-san   <unset>                 4d19h
data-orders-rabbitmq-0   Bound    pvc-905f5138-b85d-4893-9811-790e6e118620   30Gi       RWO            trident-csi-san   <unset>                 4d19h
```

Retrieve the sample application UI load-balancer address:
```
kubectl get svc -n tenant0 ui
```
Expected output:
```shell
NAME   TYPE           CLUSTER-IP      EXTERNAL-IP                                                          PORT(S)        AGE
ui     LoadBalancer   172.20.254.36   saas-fsxn-workshop-ui-de66fe501cfbfd0a.elb.us-east-1.amazonaws.com   80:30278/TCP   70m
```
::::alert{type="warning" header="Security Group changes"}
The workshop setup script automatically adds your host publicIP addess to the loadBalancer sercurity group rules (using [ipify tool](https://api.ipify.org)). If you need to access the UI from a browser located on another host make sure you add your publicIP address to the loadBalancer sercurity group rules before access. 
::::
Try to login to the sample application from the web browser:
![sample application](/static/image.png)
