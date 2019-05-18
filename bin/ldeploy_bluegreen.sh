#!/bin/bash
app=$1
version=$2
environ=$3

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh
source_app_env $app $environ

set -e
if [ "$HOSTS" ]; then
    hosts="$HOSTS"
    echo "hosts sem resolve: $hosts"
else
    hosts=$(resolve_target_hosts)
    echo "resolved hosts: $hosts"
fi
cmd=bluegreen.sh
if [ "$SLOW" == "1" ]; then
	cmd=bluegreen_slow.sh
fi
if [ "$hosts" ]; then
    echo "[BLUEGREEN] hosts pra deploy: $hosts"
    for host in $hosts; do
        ssh -o StrictHostKeyChecking=no $host dockerutils/remotebin/$cmd $app $version $environ
        echo "[BLUEGREEN] deploy feito no host $host"
    done
fi
