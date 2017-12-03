#!/bin/bash
app=$1
version=$2
environ=$3

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

set -e
hosts=$(resolve_target_hosts)
if [ "$hosts" ]; then
    echo "[BLUEGREEN] hosts pra deploy: $hosts"
    for host in $hosts; do
        $SCRIPTPATH/install_dockerutils_remote.sh $host
        ssh -o StrictHostKeyChecking=no $host dockerutils/remotebin/bluegreen.sh $app $version $environ
        echo "[BLUEGREEN] deploy feito no host $host"
    done
fi
