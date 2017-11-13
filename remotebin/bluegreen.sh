#!/bin/bash
app=$1
version=$2
environ=$3

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

resolvecolors(){
    local app=$1
    local environ=$2
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

dkstartnew(){
    local app=$1
    local environ=$2
    local nextcolor=$3
    local image=$app:$environ
    local envfile=$HOME/${app}_${environ}.env
    echo "iniciando container $nextname"
    local dkdata="$HOME/dockerdata/${app}_${environ}/$nextcolor"
    mkdir -p $dkdata
    docker stop $nextname
    docker rm $nextname
    docker run -d --name=$nextname --env-file=$envfile -v $dkdata:/dkdata $image start.sh
    echo espera subir
    docker exec $nextname wait_for_start.sh
    local exitcode=$?
    return $exitcode
}

switchtraffic() {
    echo trocando o trafego
    rm $dockerdata/current
    ln -s $dockerdata/$nextcolor $dockerdata/current
    echo "ln -s $dockerdata/$nextcolor $dockerdata/current"
}

dkstopold(){
    echo mata o velho
    local oldname=${canonized_app}_${environ}_${currcolor}
    docker exec $oldname stop.sh
    docker stop $oldname
}

# globals
canonized_app=${app/\//_}
dockerdata=$HOME/dockerdata/${app}_${environ}
resolvecolors "$app" "$environ"
nextname=${canonized_app}_${environ}_${nextcolor}

dkpull "$app" "$version" "$environ"
dkstartnew "$app" "$environ" "$nextcolor"

if [ "$?" == "0" ]; then
    switchtraffic
    dkstopold
    echo "old = $currcolor"
    echo "new = $nextcolor"
else
    echo "----------------------------------------------------"
    echo "------------------ ERRO NO DEPLOY ------------------"
    echo "----------------------------------------------------"
    docker logs $nextname
    exit $exitcode
fi
