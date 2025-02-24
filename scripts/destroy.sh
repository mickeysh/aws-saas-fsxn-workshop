#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TFDIR="$(cd ${SCRIPTDIR}/../terraform; pwd )"
LABDIR="$(cd ${SCRIPTDIR}/../labs; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

echo "Delete Lab1 content"
LAB1_DIR="${LABDIR}/lab1"
kubectl config use-context eks-primary
kubectl delete -f ${LAB1_DIR}/sample.yaml -n tenant1 --wait --ignore-not-found
kubectl delete -f ${LAB1_DIR}/svc_ldb.yaml -n tenant1 --wait --ignore-not-found
kubectl delete -f ${LAB1_DIR}/storageclass.yaml --wait --ignore-not-found
kubectl delete -f ${LAB1_DIR}/backends.yaml -n trident --wait --ignore-not-found
kubectl delete ns tenant1 --wait --ignore-not-found

echo "Delete Lab2 content"
LAB2_DIR="${LABDIR}/lab2"
kubectl config use-context eks-primary
kubectl delete -n tenant0 -f ${LAB2_DIR}/volume-snapshot.yaml --wait --ignore-not-found
kubectl delete -f ${LAB2_DIR}/volume-snapshot-class.yaml --wait --ignore-not-found

echo "Delete Lab3 content"
LAB3_DIR="${LABDIR}/lab3"
kubectl config use-context eks-dr
kubectl delete -f ${LAB3_DIR}/sample.yaml -n tenant0 --wait --ignore-not-found
kubectl delete -f ${LAB3_DIR}/mirrordest.yaml -n tenant0 --wait --ignore-not-found
kubectl delete -f ${LAB3_DIR}/pvcdest.yaml -n tenant0 --wait --ignore-not-found
kubectl config use-context eks-primary
kubectl delete -f ${LAB3_DIR}/mirrorsource.yaml -n tenant0 --wait --ignore-not-found


if [ $AWS_EXECUTION_ENV="CloudShell" ]
then 
    echo "CloudShell detected, setting terraform data directory to /home/.terraform/"
    export TF_DATA_DIR="/home/.terraform/"
fi

terraform -chdir=$TFDIR destroy -target="kubectl_manifest.sample_ap_svc_tenant0" -auto-approve
terraform -chdir=$TFDIR destroy -target="kubectl_manifest.sample_app_tenant0" -auto-approve
terraform -chdir=$TFDIR destroy -auto-approve