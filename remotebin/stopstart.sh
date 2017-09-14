#!/bin/bash
app=$1
version=$2
environ=$3
service=$4
cmd="$5"

if [ -f ~/.dockerutils/env.sh ]; then
    source ~/.dockerutils/env.sh
fi

dkpull() {
    remoteimg="$ECRHOME/$app:$version"
    aws ecr get-login --region us-east-1 --no-include-email | sh
    docker pull $remoteimg
    docker tag $remoteimg $app:$environ
    docker rmi $remoteimg
}

dkstopstart(){
    containername=${app}_${environ}_${service}
    dkdata=~/dockerdata/${app}_${environ}
    image=$app:$environ
    envfile=~/${app}_${environ}.env
    docker stop $containername
    docker rm $containername
    docker run -d --name=$containername --env-file=$envfile -v $dkdata:/dkdata $image $cmd
    exitcode=$?
    return $exitcode
}

dkpull 
dkstopstart
