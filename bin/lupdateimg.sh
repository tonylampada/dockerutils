#!/bin/bash
hosts="$1"
app=$2
version=$3
environ=$4

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

function vaiupdate(){
    host=$1
    set -e
    linstall_dockerutils_remote.sh $host
    ssh -o StrictHostKeyChecking=no $host dockerutils/remotebin/updateimg.sh $app $version $environ
}

function waitpidsaveresult() {
  p=$1
  i=$2
  set +e
  echo esperando $i $p
  wait $p
  excods[$i]=$?
  set -e
}

if [ "$hosts" ]; then
    pids=()
    excods=()
    ahosts=($hosts)
    set -e
    echo "[UPDATEIMG] hosts pra atualizar imagens: $hosts"
    for host in $hosts; do
        vaiupdate $host & pids[$i]=$!
        echo "[UPDATEIMG] imagem atualizada no host $host"
    done
    echo "vai esperar"
    for i in "${!pids[@]}"; do 
        waitpidsaveresult ${pids[$i]} $i
    done
    echo "vai sair"
    for i in "${!pids[@]}"; do 
        echo "vaiupdate no host ${ahosts[$i]} saiu com codigo ${excods[$i]}"
        if [ ${pid[$i]} != "0" ]; then
            exit ${excods[$i]}
        fi
    done
fi
