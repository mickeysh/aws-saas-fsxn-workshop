---
title : "Step 5: Deploy sample application for DR testing"
weight : 86
---

#### Deploy and test sample application with replicated data
Deploy the Application on the DR site:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl create -f sample.yaml
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
serviceaccount/catalog created
secret/catalog-db created
configmap/catalog created
service/catalog-mysql created
service/catalog created
deployment.apps/catalog created
statefulset.apps/catalog-mysql created
serviceaccount/carts created
configmap/carts created
service/carts-dynamodb created
service/carts created
deployment.apps/carts created
deployment.apps/carts-dynamodb created
serviceaccount/orders created
secret/orders-db created
secret/orders-rabbitmq created
configmap/orders created
service/orders-mysql created
service/orders-rabbitmq created
service/orders created
deployment.apps/orders created
statefulset.apps/orders-mysql created
statefulset.apps/orders-rabbitmq created
serviceaccount/checkout created
configmap/checkout created
service/checkout-redis created
service/checkout created
deployment.apps/checkout created
deployment.apps/checkout-redis created
serviceaccount/assets created
configmap/assets created
service/assets created
deployment.apps/assets created
serviceaccount/ui created
configmap/ui created
service/ui created
deployment.apps/ui created
:::
Check sample application is running:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get pods -n tenant0
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
NAME                              READY   STATUS    RESTARTS        AGE
assets-6694b7ccff-hzhl4           1/1     Running   0               2m31s
carts-8c454c85c-5ttvm             1/1     Running   1 (77s ago)     2m35s
carts-dynamodb-57dc7d97d5-5kqnf   1/1     Running   0               2m35s
catalog-6ffdd78f77-j9w2n          1/1     Running   4 (90s ago)     2m36s
catalog-mysql-0                   1/1     Running   0               2m36s
checkout-8b8548dd8-t8nrv          1/1     Running   0               2m32s
checkout-redis-78f4d66577-gsw2q   1/1     Running   0               2m32s
orders-6574497d84-6qgqk           1/1     Running   2 (64s ago)     2m34s
orders-mysql-0                    1/1     Running   1 (90s ago)     2m34s
orders-rabbitmq-0                 1/1     Running   0               2m33s
sshpod                            1/1     Running   145 (17m ago)   6d1h
ui-774d676c59-6ldx7               1/1     Running   0               2m31s
:::
