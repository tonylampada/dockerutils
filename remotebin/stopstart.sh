#!/bin/bash
app=$1
version=$2
environ=$3
service=$4
DKPARAMS="${@:5}"

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

dkstopstart(){
    containername=${canonized_app}_${environ}_${service}
    dkdata="$HOME/dockerdata/${app}_${environ}"
    image=$app:$environ
    envfile=~/${app}_${environ}.env
    (docker exec $containername stop_${service}.sh; exit 0)
    (docker stop $containername; exit 0)
    (docker rm $containername; exit 0)
    echo "stopstart with $DKPARAMS"
    docker run $DKPARAMS -d --restart=unless-stopped --name=$containername --env-file=$envfile -v $dkdata:/dkdata $image start_${service}.sh
    exitcode=$?
    return $exitcode
}

# globals
canonized_app=${app/\//_}
dkpull $app $version $environ
dkstopstart
