#!/usr/bin/env bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TFDIR="$(cd ${SCRIPTDIR}/../terraform; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

if [ -n "$AWS_EXECUTION_ENV" ] && [ "$AWS_EXECUTION_ENV" = "CloudShell" ]
then 
    echo "CloudShell detected, setting terraform data directory to /home/.terraform/"
    sudo mkdir -p /home/.terraform/
    sudo chown -R $USER:$USER /home/.terraform/
    export TF_DATA_DIR="/home/.terraform/"
fi
terraform -chdir=$TFDIR init --upgrade

echo "Deploy workshop infrastructure"
terraform -chdir=$TFDIR apply -auto-approve
terraform -chdir=$TFDIR output -json > ${SCRIPTDIR}/../labs/terraform.json