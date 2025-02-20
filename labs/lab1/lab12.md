# Lab 1 - Implement multi-tenancy using FSx for ONTAP capabilities
* Experience the different ways to isolate tenants and data on SVMs and volumes.
* Demonstrate the different ways to isolate tenants working with Labels and Selectors.
* Mapping deployments to dedicated resources (Isolating backends and EKS nodegroups).

> [!IMPORTANT]
> This lab is focused on our `eks-primary` cluster so make sure you set the context for kubectl to use that cluster by using the following command:
> ```shell
> kubectl config use-context eks-primary
> ```

### Step 1 - validate Tenant0 namespace   

```shell
kubectl get ns tenant0 
```
Expected output:
```shell
NAME      STATUS   AGE  
tenant0   Active   68m
```

### Step 2 - Validate sample app is running
```shell
kubectl get pods -n tenant0
```
Expected output:
```shell
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

### Step 3 - Display default EKS nodegroup names and custom labels created during intial setup

```shell
kubectl get nodes -o custom-columns=\\\
'NODE_NAME:.metadata.name,IP:.status.addresses[?(@.type=="InternalIP")].address,\\\
EKS_NODE_GROUP_DEFAULT_LABEL:.metadata.labels.eks\.amazonaws\.com/nodegroup,\\\
EKS_CUSTOM_LABEL:.metadata.labels.TenantName'
```

Expected output:
```shell
NODE_NAME                    IP           EKS_NODE_GROUP_DEFAULT_LABEL                      EKS_CUSTOM_LABEL
ip-10-0-1-236.ec2.internal   10.0.1.236   eks-saas-node-group-20240926065401938000000034    nodeGroupTenant0
ip-10-0-1-99.ec2.internal    10.0.1.99    eks-saas-node-group-20240926065401938000000034    nodeGroupTenant0
ip-10-0-2-195.ec2.internal   10.0.2.195   eks-saas-node-group2-20240926065401938000000032   nodeGroupTenant1
ip-10-0-2-205.ec2.internal   10.0.2.205   eks-saas-node-group2-20240926065401938000000032   nodeGroupTenant1
```


