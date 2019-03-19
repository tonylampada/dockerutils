#!/bin/bash
app=$1
version=$2
environ=$3
service=$4
DKPARAMS="${@:5}"

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh
source_app_env $app $environ

dkstopstart(){
    containername=${canonized_app}_${environ}_${service}
    dkdata="$HOME/dockerdata/${app}_${environ}"
    image=$app:$environ
    envfile=~/${canonized_app}_${environ}.env
    docker exec $containername stop_${service}.sh || true
    docker stop $containername || true
    docker rm $containername || true
    echo "stopstart with $DKPARAMS"
    docker run $DKPARAMS -d --name=$containername --env-file=$envfile -v $dkdata:/dkdata $image start_${service}.sh
    exitcode=$?
    return $exitcode
}

# globals
set -e
canonized_app=${app/\//_}
dkstopstart

