---
title : "Step 3: Validate the catalog after updates"
weight : 74
---

#### Validate the catalog after updates
Next we'll verify the item we added to the catalog and assets services.
#### Check additionl item in the product catalog
List the new image we added to the assets file share
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl exec -n tenant0 --stdin deployment/assets -- bash -c 'ls /usr/share/nginx/html/assets'
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=true language=shell}
chrono_classic.jpg
cuckoo.jpg
gentleman.jpg
pocket_watch.jpg
smart_1.jpg
smart_2.jpg
wood_watch.jpg
:::

Log in to tenant0 web ui and check the store catalog. You should now see 7 items in the catalog. 

![step0-webui](/static/lab2-step3-0.png)

Select the new item in the catalog and check it out:

![step0-webui](/static/lab2-step3-1.png)

Now lets restore our tenants` product catalog to the backup point in time. 