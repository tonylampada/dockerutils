#!/bin/bash
app=$1
version=$2
environ=$3

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

dkmigratedb(){
    containername=${app}_${environ}_migratedb
    image=$app:$environ
    envfile=~/${app}_${environ}.env
    docker run --rm --name=$containername --env-file=$envfile $image migratedb.sh
    exitcode=$?
    return $exitcode
}

dkpull $app $version $environ
dkmigratedb
