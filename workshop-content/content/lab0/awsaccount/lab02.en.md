---
title : "Step 3: Create Workshop Infrastructure"
weight : 63
---

## Create Workshop Infrastructure
Enter the following into your terminal:
:::code{showCopyAction=true showLineNumbers=false language=shell}
sh ./scripts/deploy.sh
:::
In the following sections, we'll be using `kubectl` to deploy and manage services. In order for `kubectl` to work, we need to ensure it's configured to talk to our newly deployed EKS clusters. When the script finishes running, it outputs a number of variables to the screen. Two of of which are the commands you use to update our kubeconfig with the information required to connect to our EKS clusters. The output variables are zz_update_kubeconfig_command for the primary cluster and zz_update_kubeconfig_command2 for the DR cluster as seen in the sample below
::::alert{type="info" header="Terraform outputs"}
To get these variable values you can always navigate into the ../terraform directory and use `terraform output` command to generate the state of the outputs for these workshop. We will use and refer to all of them throughout the workshop process.
::::
:::code{showCopyAction=false showLineNumbers=false language=shell}
Outputs:

cluster_peer_destenation = "cluster peer create -address-family ipv4 -peer-addrs 10.0.1.139,10.0.1.232"
cluster_peer_source = "cluster peer create -address-family ipv4 -peer-addrs 10.1.1.10,10.1.1.136"
fsx-dr-management-ip = toset([
  "10.1.1.92",
])
fsx-management-ip = toset([
  "10.0.1.126",
])
fsx-ontap-id = "fs-013b852f46d03ab97"
fsx-password = <fsx-password>
fsx-svm-name = "ekssvm"
fsx-svmdr-name = "ekssvmdr"
fsx2-ontap-id = "fs-0c2fcb7709de5be8e"
region = <region>
secret_arn = "arn:aws:secretsmanager:<region>:<account-id>:secret:fsxn-password-secret-SJcLlRXx-yY0pCt"
svm_peer_destination = "vserver peer create -vserver ekssvmdr -peer-vserver ekssvm -peer-cluster FsxId013b852f46d03ab97 -applications snapmirror"
svm_peer_source = "vserver peer accept -vserver ekssvm -peer-vserver ekssvmdr"
zz_update_kubeconfig_command = "aws eks update-kubeconfig --name eks-saas-SJcLlRXx --alias eks-primary --region us-east-1"
zz_update_kubeconfig_command2 = "aws eks update-kubeconfig --name eks-saas-dr-SJcLlRXx --alias eks-dr --region us-east-1"
:::
Copy the value of that output and run it in your terminal window. The command will be similar, but not identical to the command below:
::::alert{type="warning" header="EKS update kubeconfig"}
The command below is a sample and will not work for your cluster
::::
:::code{showCopyAction=true showLineNumbers=true language=shell}
aws eks update-kubeconfig --name eks-saas-SJcLlRXx --alias eks-primary --region us-east-1
aws eks update-kubeconfig --name eks-saas-dr-SJcLlRXx --alias eks-dr --region us-east-1
:::
Once executed, you should be provided an Added new context... message. Execute the below command to confirm that you are able to access the EKS cluster.
::::alert{type="info" header="Changing kubectl context throughout the workshop"}
We will use the kubectl config use-context `kubectl config use-context` command throughout the labs to switch between the kubernetes clusters.
::::
To test access to both clusters use the following commands:
:::code{showCopyAction=true showLineNumbers=true language=shell}
kubectl config use-context eks-primary
kubectl get nodes
kubectl config use-context eks-dr
kubectl get nodes
:::
This should see an output with the name of the nodes in both `eks-primary` and `eks-dr` Amazon EKS clusters. Next we'll verify the deployed sample application.  