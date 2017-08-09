#!/bin/bash
app=$1
version=$2
environ=$3

if [ -f ~/.dockerutils/env.sh ]; then
    source ~/.dockerutils/env.sh
fi

dkpull() {
    remoteimg="$ECRHOME/$app:$version"
    aws ecr get-login --region us-east-1 --no-include-email | sh
    docker pull $remoteimg
    docker tag $remoteimg $app:$environ
}

dkmigratedb(){
    containername=${app}_${environ}_migratedb
    image=$app:$environ
    envfile=~/${app}_${environ}.env
    docker run --rm --name=$containername --env-file=$envfile $image migratedb.sh
    exitcode=$?
    return $exitcode
}

dkpull 
dkmigratedb
