if [ -f ~/.dockerutils/env.sh ]; then
    source ~/.dockerutils/env.sh
fi

dklogin() {
    local app=$1
    local version=$2
    local environ=$3

    if [ "$DOCKER_REGISTRY_TYPE" = "ec2" ]; then
        aws ecr get-login --region us-east-1 --no-include-email | sh
        return 0
    elif [ "$DOCKER_REGISTRY_TYPE" = "gitlab" ]; then
        docker login -u "$DOCKER_GITLAB_USERNAME" -p "$DOCKER_GITLAB_PASSWORD" "$DOCKER_REGISTRY"
        return 0
    else
        echo "[ERROR] Unknown DOCKER_REGISTRY_TYPE!"
        return 1
    fi
}

resolve_target_hosts() {
    if [ "aws_asg" == "$TARGET_TYPE" ]; then
        list_asg.sh $ASG
    else
        echo $HOST
    fi
}

dkpull() {
    local app=$1
    local version=$2
    local environ=$3
    local remoteimg="$DOCKER_REGISTRY/$app:$version"
    local localimg="$app:$environ"

    dklogin
    docker pull $remoteimg
    docker tag $remoteimg $localimg
    docker rmi $remoteimg
}