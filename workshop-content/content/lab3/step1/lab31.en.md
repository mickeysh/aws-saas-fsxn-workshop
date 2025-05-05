---
title : "Step 1: Create peering between the production and DR FSxN filesystems (Alternative)"
weight : 82
---

::::alert{type="info" header="Cluster Peering Alternative Method"}
This is an automated alternative way to peer the FSxN file-systems. If you want to fully undertand the process of the file-system peering you can [follow the instuctions on the previous page](/lab3/step1/lab30).
::::

#### FSxN Cluster Peering
::::alert{type="warning" header="EKS Cluster Context Setup"}
This part of the lab is focused on our `eks-primary` cluster so make sure you set the context for kubectl to use that cluster by using the following command:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl config use-context eks-primary
:::
::::

To peer the two FSxN file-systems we'll use the peering utility and run it as a Job. You can [read more about this utility and how to use it here](https://gallery.ecr.aws/netapp-innovation/fsxn/ontap-peering). 

Run the job using `peercreate.yaml` sample file:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl apply -f ../labs/lab3/peercreate.yaml
:::

You can verify the process by checking the output of the job. You'll need to get the pod id first:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl get pods -l job-name=peer-clusters-create -n trident
:::
Expected output:
:::code{showCopyAction=false showLineNumbers=false language=shell}
NAME                         READY   STATUS      RESTARTS   AGE
peer-clusters-create-nb2cs   0/1     Completed   0          54m
::::
And then query the Pod's logs:
:::code{showCopyAction=true showLineNumbers=false language=shell}
kubectl logs -n trident peer-clusters-create-nb2cs
::::

Expected output: 
:::code{showCopyAction=false showLineNumbers=false language=shell}
INFO:root:Preparing for peering FSxN Clusters
INFO:root:Source Cluster: fs-073125efa2d14fec5, SVM: ekssvm
INFO:root:Destenation Cluster: fs-02ed7e71802b7fbe7, SVM: ekssvmdr
INFO:root:AWS Region: us-west-2
INFO:root:Create: True, Cleanup: True
INFO:root:Feching secret values from secretID: arn:aws:secretsmanager:us-west-2:139763910815:secret:fsxn-password-secret-lCaPJj6Y-LyaSxs
INFO:root:Feching secret values from secretID: arn:aws:secretsmanager:us-west-2:139763910815:secret:fsxn-password-secret-lCaPJj6Y-LyaSxs
INFO:root:Fetching FSxN Clusters details
INFO:root:Fetching FSxN Clusters details
INFO:root:Logging into host at ip address: 10.1.1.149
INFO:root:Cleaning up Peers
INFO:root:Logging into host at ip address: 10.0.1.253
INFO:root:Cleaning up Peers
INFO:root:Logging into host at ip address: 10.1.1.149
INFO:root:Creating Cluster Peer
INFO:root:Created Cluster Peer UUID: a71baf40-268b-11f0-9178-4d5e657f7b48 at status ClusterPeerStatus({'state': 'unavailable'})
INFO:root:Logging into host at ip address: 10.0.1.253
INFO:root:Creating Cluster Peer
INFO:root:Created Cluster Peer UUID: bb9c018e-268b-11f0-aa85-b9e24d35d27e at status ClusterPeerStatus({'state': 'available', 'update_time': '2025-05-04T17:26:31+00:00'})
INFO:root:Logging into host at ip address: 10.1.1.149
INFO:root:Creating SVM Peer
INFO:netapp_ontap.utils:Job (running): success. Timeout remaining: 30.
INFO:root:Created SVM Peer UUID: eb6798f4-290c-11f0-aa85-b9e24d35d27e at status initiated
INFO:root:Logging into host at ip address: 10.0.1.253
INFO:root:Accepting SVM Peer
INFO:netapp_ontap.utils:Job (success): success. Timeout remaining: 25.
INFO:root:Created Source SVM Peer UUID: eb6798f4-290c-11f0-aa85-b9e24d35d27e at status peered
:::

Now that we have both FSxN file-systems and SVM peered we can start replicating PVCs between these clusters.