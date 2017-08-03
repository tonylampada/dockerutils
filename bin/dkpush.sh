#!/bin/bash
app=$1
version=$2

if [ -f ~/.dockerutils/env.sh ]; then
    source ~/.dockerutils/env.sh
fi
aws ecr get-login --region us-east-1 | sh
imglocal=$app:latest
imgremote=$ECRHOME/$app:$version
docker tag $imglocal $imgremote
echo "pushing docker image $imgremote ..."
docker push $imgremote
