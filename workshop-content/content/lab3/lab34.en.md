---
title : "Step 4: Move the sample application to the eks-dr cluster"
weight : 85
---
In order to deploy our application on the DR cluster we need to convert the PVCs to R/W state and pause the Snapmirror replication. 

::::alert{type="warning" header="EKS Cluster Context Setup"}
This part of the lab is focused on our `eks-dr` cluster so make sure you set the context for kubectl to use that cluster by using the following command:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl config use-context eks-dr
:::
::::
#### Stop the mirroring on the eks-dr cluster and promote PVC to R/W status
Stop the mirroring and make the local volume on the DR cluster R/W and mountable. Use [mirrordestdr.yaml](mirrordestdr.yaml) manifest to change the mirror relationship from `established` to `promoted`.
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl apply -n tenant0 -f mirrordestdr.yaml
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=true language=shell}
tridentmirrorrelationship.trident.netapp.io/assets-share configured
tridentmirrorrelationship.trident.netapp.io/data-catalog-mysql-0 configured
tridentmirrorrelationship.trident.netapp.io/data-orders-mysql-0 configured
tridentmirrorrelationship.trident.netapp.io/data-orders-rabbitmq-0 configured
:::

Validate that the mirror relationship actual state was set to promoted (during the process the actual state might be `promoting` before changing to `promoted`)
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get tmr -n tenant0
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
NAME                     DESIRED STATE   LOCAL PVC                ACTUAL STATE   MESSAGE
assets-share             promoted        assets-share             promoted       
data-catalog-mysql-0     promoted        data-catalog-mysql-0     promoted       
data-orders-mysql-0      promoted        data-orders-mysql-0      promoted       
data-orders-rabbitmq-0   promoted        data-orders-rabbitmq-0   promoted       
:::
Now that we have the PVCs set to R/W and the replication paused we can deploy our tenant's application stack on the DR cluster.