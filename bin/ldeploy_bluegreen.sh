#!/bin/bash
app=$1
version=$2
environ=$3

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh
source_app_env $app $environ

function vaibluegreen(){
    host=$1
    set -e
    ssh -o StrictHostKeyChecking=no $host dockerutils/remotebin/$cmd $app $version $environ
    echo "[BLUEGREEN] deploy feito no host $host"

}

function waitpidsaveresult() {
  p=$1
  i=$2
  set +e
  wait $p
  excods[$i]=$?
  set -e
}

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
    pids=()
    excods=()
    ahosts=($hosts)

    echo "[BLUEGREEN] hosts pra deploy: $hosts"

    i=0
    for host in $hosts; do
        echo "[BLUEGREEN] iniciando em $host"
        vaibluegreen $host & pids[$i]=$!
        i=$(($i+1))
    done
    for i in "${!pids[@]}"; do 
        waitpidsaveresult ${pids[$i]} $i
    done

    for i in "${!pids[@]}"; do 
        if [ ${excods[$i]} != "0" ]; then
          echo "vaibluegreen no host ${ahosts[$i]} saiu com codigo ${excods[$i]}"
            exit ${excods[$i]}
        fi
    done
fi
