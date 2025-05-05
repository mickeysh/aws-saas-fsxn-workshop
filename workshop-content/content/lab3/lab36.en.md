---
title : "Step 6: Validate the DR application after failover"
weight : 87
---
Check the assets service volume content. You should see 6 images:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl exec -n tenant0 --stdin deployment/assets -- bash -c 'ls /usr/share/nginx/html/assets'
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
chrono_classic.jpg
gentleman.jpg
pocket_watch.jpg
smart_1.jpg
smart_2.jpg
wood_watch.jpg
:::
Check product catalog in tenant0 sample application by logging into the web ui and selecting the product catalog. After the restore you should now see the original 6 items available at the catalog.
::::alert{type="info" header="Get sample app external UI"}
You can use the External public name to open the catalog for each tenant and compare
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get svc ui -n tenant0 --output jsonpath='{.status.loadBalancer.ingress[0].hostname}'
:::
::::
![step0-webui](/static/lab2-step6.png)
