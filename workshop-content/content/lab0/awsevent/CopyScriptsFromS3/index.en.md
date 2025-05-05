---
title : "Step 2: Copy lab scripts from S3"
weight : 92
---

Steps to copy lab scripts from S3

# Objectives
Copy lab scripts from S3 bucket created in this AWS account. These scripts are needed to run upcoming labs! 
Perfom below steps in the Cloudshell.
 

```shell
mkdir labs
cd labs
aws s3 ls
```
Previous step will list the S3 bucket that has the lab scripts:
```shell
aws s3 sysnc s3://<bucket name from previous step> .
pwd
ls -l
```
Previous step will list the lab scrpts in the labs folder as shown below:


![step0-webui](/static/s3_scripts_1.png)