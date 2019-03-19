#!/bin/bash
hosts="$1"
app=$2
version=$3
environ=$4

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

source_app_env $app $environ

function vaiupdate(){
    host=$1
    set -e
    linstall_dockerutils_remote.sh $host
    ssh -o StrictHostKeyChecking=no $host dockerutils/remotebin/updateimg.sh $app $version $environ
    echo "[UPDATEIMG] imagem atualizada no host $host"
}

# function waitpidsaveresult() {
#   p=$1
#   i=$2
#   set +e
#   wait $p
#   excods[$i]=$?
#   set -e
# }

if [ "$hosts" ]; then
    pids=()
    excods=()
    ahosts=($hosts)
    set -e
    echo "[UPDATEIMG] hosts pra atualizar imagens: $hosts"
    for host in $hosts; do
        echo "[UPDATEIMG] iniciando em $host"
        vaiupdate $host
    done
    echo "[UPDATEIMG] done"
fi
