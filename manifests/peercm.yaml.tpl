apiVersion: v1
kind: ConfigMap
metadata:
  name: ${peer_name}
  namespace: trident
data:
  parms.json: |
    {
        "source": {
            "fsID": "${fs_id}",
            "svmName": "${svm_name}",
            "secretId": "${secret_id}"
        }, 
        "destenation":{
            "fsID": "${fs_dr_id}",
            "svmName": "${svm_dr_name}",
            "secretId": "${secret_id}"
        },
        "cleanup": true,
        "create": ${peer_create},
        "region": "${region}"
    }