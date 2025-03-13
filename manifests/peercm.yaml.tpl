apiVersion: v1
kind: ConfigMap
metadata:
  name: peer-parms
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
        "create": false,
        "region": "${region}"
    }