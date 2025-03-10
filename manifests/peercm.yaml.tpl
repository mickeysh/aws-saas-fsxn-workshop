apiVersion: v1
kind: ConfigMap
metadata:
  name: peer-parms
  namespace: trident
data:
  parms.json: |
    {
        "secretId": "${secret_id}",
        "source": {
            "fsID": "${fs_id}",
            "svmName": "${svm_name}"
        }, 
        "destenation":{
            "fsID": "${fs_dr_id}",
            "svmName": "${svm_dr_name}"
        },
        "cleanup": true,
        "create": false,
        "region": "${region}"
    }