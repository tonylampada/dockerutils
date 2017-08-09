#!/bin/bash
app=$1
version=$2
environ=$3

if [ -f ~/.dockerutils/env.sh ]; then
    source ~/.dockerutils/env.sh
fi

resolvecolors(){
    dockerdata=~/dockerdata/${app}_${environ}
    mkdir -p $dockerdata
    chmod o+r $dockerdata
    if [ -L $dockerdata/current ]
    then
        currsock=$(readlink -f $dockerdata/current)
        if [ "$currsock" == "$dockerdata/blue" ]
        then
            currcolor=blue
            nextcolor=green
        else
            currcolor=green
            nextcolor=blue
        fi
    else
        ln -s $dockerdata/blue $dockerdata/current
        currcolor=blue
        nextcolor=green
    fi

}

dkpull() {
    remoteimg="$ECRHOME/$app:$version"
    aws ecr get-login --region us-east-1 --no-include-email | sh
    docker pull $remoteimg
    docker tag $remoteimg $app:$environ
    docker tag $remoteimg $app:${environ}_${nextcolor}
}

dkstartnew(){
    nextname=${app}_${environ}_${nextcolor}
    image=$app:$environ
    envfile=~/${app}_${environ}.env
    echo iniciando container
    dkdata="$dockerdata/$nextcolor"
    mkdir -p $dkdata
    sudo rm -Rf $dkdata/*
    docker stop $nextname
    docker rm $nextname
    docker run -d --name=$nextname --env-file=$envfile -v $dkdata:/dkdata $image start.sh
    echo espera subir
    docker exec $nextname wait_for_start.sh
    exitcode=$?
    return $exitcode
}

switchtraffic() {
    echo trocando o trafego
    rm $dockerdata/current
    ln -s $dockerdata/$nextcolor $dockerdata/current
}

dkstopold(){
    echo mata o velho
    oldname=${app}_${environ}_${currcolor}
    docker exec $oldname stop.sh
    docker stop $oldname
}


resolvecolors
dkpull 
dkstartnew
if [ "$exitcode" == "0" ]; then
    switchtraffic
    dkstopold
    echo "old = $currcolor"
    echo "new = $nextcolor"
else
    echo "----------------------------------------------------"
    echo "------------------ ERRO NO DEPLOY ------------------"
    echo "----------------------------------------------------"
    exit $exitcode
fi
