#!/bin/bash
app=$1
version=$2
environ=$3
service=$4

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

dkstopstart(){
    containername=${app}_${environ}_${service}
    dkdata="$HOME/dockerdata/${app}_${environ}"
    image=$app:$environ
    envfile=~/${app}_${environ}.env
    docker exec $containername stop_${service}.sh
    docker stop $containername
    docker rm $containername
    docker run -d --restart=unless-stopped --name=$containername --env-file=$envfile -v $dkdata:/dkdata $image start_${service}.sh
    exitcode=$?
    return $exitcode
}

dkpull $app $version $environ
dkstopstart
