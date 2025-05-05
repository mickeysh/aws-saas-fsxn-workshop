---
title : "Step 5: Testing the tenant's data"
weight : 68
---
Log in to tenant1 web ui and check the store catalog. You should now see 7 items in the catalog. 
::::alert{type="info" header="Get sample app external UI"}
You can use the External public name to open the catalog for each tenant and compare
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get svc ui -n tenant0 --output jsonpath='{.status.loadBalancer.ingress[0].hostname}'
kubectl get svc ui -n tenant1 --output jsonpath='{.status.loadBalancer.ingress[0].hostname}'
:::
::::
The expected output is the public host name of tenant0 and tenant1 sample application

Use your browser to login into both tenets and compare tenant0 and tenant1 web catalogs:

### Tenant0:

![lab1-webui](/static/lab1-step5-0.png)

### Tenant1:

![lab1-webui](/static/lab1-step5-1.png)

That's it! You've finished this lab. 
