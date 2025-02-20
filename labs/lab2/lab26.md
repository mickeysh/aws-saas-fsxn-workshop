## Validate the catalog after restore

### Step 9 -  Verify the restored application
Check the assets service volume content. You should see 6 images as it was before the images download:
```shell
kubectl exec -n tenant0 --stdin deployment/assets -- bash -c 'ls /usr/share/nginx/html/assets' 
```
Expected output:
```shell
/usr/share/nginx/html/assets'
chrono_classic.jpg
gentleman.jpg
pocket_watch.jpg
smart_1.jpg
smart_2.jpg
wood_watch.jpg
```

Log in to the Catalog MySQL server:
```
kubectl exec -it catalog-mysql-0 -n tenant0 -- mysql -u root -pmy-secret-pw
```
Expected output:
```
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 5.7.44 MySQL Community Server (GPL)

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```
Check the products in the catalog:
```
use catalog
select * from product;
exit
```
Expected output:
```
mysql> use catalog
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed

mysql> select * from product;
+--------------------------------------+--------------------+------------------------------------------+-------+-------+----------------------------+
| product_id                           | name               | description                              | price | count | image_url                  |
+--------------------------------------+--------------------+------------------------------------------+-------+-------+----------------------------+
| 510a0d7e-8e83-4193-b483-e27e09ddc34d | Gentleman          | Touch of class for a bargain.            |   795 |    51 | /assets/gentleman.jpg      |
| 6d62d909-f957-430e-8689-b5129c0bb75e | Pocket Watch       | Properly dapper.                         |   385 |    33 | /assets/pocket_watch.jpg   |
| 808a2de1-1aaa-4c25-a9b9-6612e8f29a38 | Chronograf Classic | Spend that IPO money                     |  5100 |     9 | /assets/chrono_classic.jpg |
| a0a4f044-b040-410d-8ead-4de0446aec7e | Wood Watch         | Looks like a tree                        |    50 |   115 | /assets/wood_watch.jpg     |
| ee3715be-b4ba-11ea-b3de-0242ac130004 | Smart 3.0          | Can tell you what you want for breakfast |   650 |     9 | /assets/smart_1.jpg        |
| f4ebd070-b4ba-11ea-b3de-0242ac130004 | FitnessX           | Touch of class for a bargain.            |   180 |    76 | /assets/smart_2.jpg        |
+--------------------------------------+--------------------+------------------------------------------+-------+-------+----------------------------+
6 rows in set (0.00 sec)

mysql> exit
Bye
```

Check product catalog in tenant0 sample application by logging into the web ui and selecting the product catalog. After the restore you should now see the original 6 items available at the catalog.

![step0-webui](images/lab2-step6.png)