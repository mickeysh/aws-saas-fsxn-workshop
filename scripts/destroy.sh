#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TFDIR="$(cd ${SCRIPTDIR}/../terraform; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

if [ $AWS_EXECUTION_ENV="CloudShell" ]
then 
    echo "CloudShell detected, setting terraform data directory to /home/.terraform/"
    export TF_DATA_DIR="/home/.terraform/"
fi

terraform -chdir=$TFDIR destroy -target="kubectl_manifest.sample_ap_svc_tenant0" -auto-approve
terraform -chdir=$TFDIR destroy -target="kubectl_manifest.sample_app_tenant0" -auto-approve
terraform -chdir=$TFDIR destroy -auto-approve