#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TFDIR="$(cd ${SCRIPTDIR}/../terraform; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

terraform -chdir=$TFDIR init --upgrade

echo "Deploy workshop infrastructure"
terraform -chdir=$TFDIR apply -auto-approve