#!/bin/bash
app=$1
version=$2
environ=$3
service=$4
cmd="$5"

DKU="$(dirname ${BASH_SOURCE[0]})/.."
source $DKU/commons/aws.env

dkpull() {
    remoteimg="$ECRHOME/$app:$version"
    aws ecr get-login --region us-east-1 | sh
    docker pull $remoteimg
    docker tag $remoteimg $app:$environ
}

dkstopstart(){
    containername=${app}_${environ}_${service}
    image=$app:$environ
    envfile=~/${app}_${environ}.env
    docker stop $containername
    docker rm $containername
    docker run -d --restart=unless-stopped --name=$containername --env-file=$envfile $image $cmd
    exitcode=$?
    return $exitcode
}

dkpull 
dkstopstart
