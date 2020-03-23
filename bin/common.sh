if [ -f ~/.dockerutils/env.sh ]; then
    source ~/.dockerutils/env.sh
fi

source_app_env() {
    local app=$1
    local environ=$2

    if [ "$app" == "" -o "$environ" == "" ]; then
        return;
    fi

    if [ -e "$HOME/.dockerutils/${app}_${environ}/env.sh" ]; then
        echo "Sourcing $HOME/.dockerutils/${app}_${environ}/env.sh ..."
        source $HOME/.dockerutils/${app}_${environ}/env.sh
    fi
}

dklogin() {
    if [ ! "$AWS_PROFILE" ]; then
        AWS_PROFILE=default
    fi
    if [ "$DOCKER_REGISTRY_TYPE" = "ec2" ]; then
        aws ecr get-login --profile "$AWS_PROFILE" --no-include-email | sh
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
    elif [ "aws_tsg" == "$TARGET_TYPE" ]; then
        list_tsg.sh $TSG
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

    docker pull $remoteimg
    docker tag $remoteimg $localimg
    docker rmi $remoteimg
}
