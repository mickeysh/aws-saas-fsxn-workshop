## Move the sample application to the eks-dr cluster

### Step 6 - Stop the mirroring on the eks-dr cluster and promote PVC to R/W status
Stop the mirroring and make the local volume on the DR cluster R/W and mountable. Use [mirrordestdr.yaml](mirrordestdr.yaml) manifest to change the mirror relationship from `established` to `promoted`.
```shell
kubectl apply -n tenant0 -f mirrordestdr.yaml
```
Expected output:
```shell
tridentmirrorrelationship.trident.netapp.io/assets-share configured
tridentmirrorrelationship.trident.netapp.io/data-catalog-mysql-0 configured
tridentmirrorrelationship.trident.netapp.io/data-orders-mysql-0 configured
tridentmirrorrelationship.trident.netapp.io/data-orders-rabbitmq-0 configured
```

Validate that the mirror relationship actual state was set to promoted (during the process the actual state might be `promoting` before changing to `promoted`)
```bash
> kubectl get tmr -n tenant0
NAME                     DESIRED STATE   LOCAL PVC                ACTUAL STATE   MESSAGE
assets-share             promoted        assets-share             promoted       
data-catalog-mysql-0     promoted        data-catalog-mysql-0     promoted       
data-orders-mysql-0      promoted        data-orders-mysql-0      promoted       
data-orders-rabbitmq-0   promoted        data-orders-rabbitmq-0   promoted       
```