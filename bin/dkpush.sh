#!/bin/bash
app=$1
version=$2

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

imglocal=$app:latest
imgremote=$DOCKER_REGISTRY/$app:$version

dklogin
docker tag $imglocal $imgremote
echo "pushing docker image $imgremote ..."
docker push $imgremote
