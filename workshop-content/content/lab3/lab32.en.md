---
title : "Step 2: Ceate Snapmirror relationships to PVCs"
weight : 83
---

Next we'll use the NetApp Trident CRDs to create a snapmirror relationship between out sample application's PVCs. 

#### Create Mirror relationships on the source PVCs

1) Create the Trident Snapmirror resources using `mirrorsource.yaml` manifest:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl create -f mirrorsource.yaml -n tenant0
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=true language=shell}
tridentmirrorrelationship.trident.netapp.io/assets-share created
tridentmirrorrelationship.trident.netapp.io/data-catalog-mysql-0 created
tridentmirrorrelationship.trident.netapp.io/data-orders-mysql-0 created
tridentmirrorrelationship.trident.netapp.io/data-orders-rabbitmq-0 created
:::
Check the mirror relationships on the source cluster:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get tmr -n tenant0
:::
Expected outout:
:::code{showCopyAction=false showLineNumbers=false language=shell}
NAME                     DESIRED STATE   LOCAL PVC                ACTUAL STATE   MESSAGE
assets-share             promoted        assets-share             promoted       
data-catalog-mysql-0     promoted        data-catalog-mysql-0     promoted       
data-orders-mysql-0      promoted        data-orders-mysql-0      promoted       
data-orders-rabbitmq-0   promoted        data-orders-rabbitmq-0   promoted       
:::
Get the FSxN local volume handles for all PVCs:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get tmr -n tenant0 -o=jsonpath="{range .items[*]}[{.metadata.name},{.status.conditions[0].localVolumeHandle}]{'\n'}{end}"
:::
Expected output:
::::alert{type="warning" header="Requirement for next step"}
This list will be required on the next step to complete the snapmirror relationship on the `eks-dr` cluster. 
::::
:::code{showCopyAction=false showLineNumbers=true language=shell}
[assets-share,ekssvm:trident_pvc_cb387eef_3fa7_46f2_b726_1682c777b1a6]
[data-catalog-mysql-0,ekssvm:trident_pvc_bfc62dea_fa19_45dd_acbd_612e4b271876]
[data-orders-mysql-0,ekssvm:trident_pvc_19880815_9777_41cf_9def_5b83e4cbbe9e]
[data-orders-rabbitmq-0,ekssvm:trident_pvc_c18a60ff_723d_45a2_b40c_4d84934d38ba]
:::

