---
title : "Step 4: Login to application and change database"
weight : 67
---
On this step you are going to login to the new tenant1 application, make changes to the database and compare the the two applications between tenant0 and tenant1.
* Login to the tenant1 application 
* Change the application database 
* Compare tenant0 and tenant1 applications 

Login to the tenant1 application MySQL server:

:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl exec -it catalog-mysql-0 -n tenant1 -- mysql -u root -pmy-secret-pw
:::
Expected output
:::code{showCopyAction=false showLineNumbers=false language=shell}
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 5.7.44 MySQL Community Server (GPL)

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
:::

Change application database and add a new product to the catalog database:
:::code{showCopyAction=false showLineNumbers=false language=shell}
#### sql command to use catalog 
mysql> use catalog
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed

#### List all products in catalog database 
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


#### Add cockoo clock to catalog 
mysql> INSERT INTO product VALUES ("f4ebd070-b4ba-11ea-b3de-4de0446aec7e", "Cuckoo clock", "Great for bird lovers.",  550, 3, "/assets/cuckoo.jpg");
Query OK, 1 row affected (0.00 sec)

#### Insert product tag for cockoo clock 
mysql> INSERT INTO product_tag VALUES ("f4ebd070-b4ba-11ea-b3de-4de0446aec7e", "1");
Query OK, 1 row affected (0.00 sec)

#### Updated list with new item cockoo clock
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
| f4ebd070-b4ba-11ea-b3de-4de0446aec7e | Cuckoo clock       | Great for bird lovers.                   |   550 |     3 | /assets/cuckoo.jpg         |
+--------------------------------------+--------------------+------------------------------------------+-------+-------+----------------------------+
7 rows in set (0.00 sec)

#### exit database 
mysql> exit
Bye
:::

Add a new Image to for the new product we just created in the catalog. 
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl exec --stdin deployment/assets -n tenant1 -- bash -c 'curl https://upload.wikimedia.org/wikipedia/commons/f/fc/Du200613.png -o /usr/share/nginx/html/assets/cuckoo.jpg'
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  116k  100  116k    0     0   887k      0 --:--:-- --:--:-- --:--:--  890k
:::
Verify available catalog images: 
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl exec -n tenant1 --stdin deployment/assets -- bash -c 'ls /usr/share/nginx/html/assets'
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
chrono_classic.jpg
cuckoo.jpg
gentleman.jpg
pocket_watch.jpg
smart_1.jpg
smart_2.jpg
wood_watch.jpg
:::

