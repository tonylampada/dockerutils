#!/bin/bash
app=$1
version=$2
environ=$3
service=$4
DKPARAMS="$5"

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

source_app_env $app $environ

set -e
DKU="$(dirname ${BASH_SOURCE[0]})/.."
hosts=$(resolve_target_hosts)
if [ "$hosts" ]; then
    echo "[STOPSTART] hosts pra iniciar $service: $hosts"
    echo "[STOPSTART] DKPARAMS=$DKPARAMS"
    for host in $hosts; do
        ssh -o StrictHostKeyChecking=no $host dockerutils/remotebin/stopstart.sh $app $version $environ $service "$DKPARAMS"
        echo "[STOPSTART] $service iniciado no host $host"
    done
fi
