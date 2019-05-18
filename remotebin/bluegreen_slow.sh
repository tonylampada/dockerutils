#!/bin/bash
app=$1
version=$2
environ=$3

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh
source_app_env $app $environ

resolvecolors(){
    local app=$1
    local environ=$2
    mkdir -p $dockerdata
    chmod o+r $dockerdata
    set +e
    isblue=$(docker ps | grep ${app}_${environ}_blue)
    isgreen=$(docker ps | grep ${app}_${environ}_green)
    set -e
    if [ "$isblue" ]
    then
        currcolor=blue
        nextcolor=green
    elif [ "$isgreen" ]
    then
        currcolor=green
        nextcolor=blue
    else
        currcolor=""
        nextcolor=blue
    fi
}

dkstartnew(){
    local app=$1
    local environ=$2
    local nextcolor=$3
    local image=$app:$environ
    local envfile=$HOME/${canonized_app}_${environ}.env
    echo "iniciando container $nextname"
    local dkdata="$HOME/dockerdata/${app}_${environ}/$nextcolor"
    mkdir -p $dkdata
    docker stop $nextname || true
    docker rm $nextname || true
    docker run -d --restart=unless-stopped --name=$nextname --env-file=$envfile -v $dkdata:/dkdata $image start.sh
    echo espera subir
    docker exec $nextname wait_for_start.sh
    local exitcode=$?
    return $exitcode
}

sendsometraffic() {
    nextweight=$1
    filename="/etc/nginx/sites-enabled/${app}_upstreams.conf"
    echo "upstream $app {" > $filename
    currweight=$((1000 - $nextweight))
    if [ "$currweight" != "0" ]
    then
        echo "    server unix:////home/ubuntu/dockerdata/${app}_${environ}/${currcolor}/nginx.sock weight=${currweight};" >> $filename
        echo "    server unix:////home/ubuntu/dockerdata/${app}_${environ}/${nextcolor}/nginx.sock weight=${nextweight};" >> $filename
        echo "}" >> $filename
    else
        echo "    server unix:////home/ubuntu/dockerdata/${app}_${environ}/${nextcolor}/nginx.sock;" >> $filename
        echo "}" >> $filename
    fi
    sudo service nginx reload
}

switchtraffic() {
    echo trocando o trafego
    if [ "$currcolor" ]
    then
        ws="10 40 90 160 250 360 490 640 810 1000"
        for w in $ws
        do
            echo "trocando trafego $w/1000..."
            sendsometraffic $w
            sleep 10
        done
    else
        echo "trocando trafego 1000/1000..."
        sendsometraffic 1000
    fi
    echo "trocou!"
}

dkstopold(){
    if [ "$currcolor" ]
    then
        echo assim vc mata o velho
        local oldname=${canonized_app}_${environ}_${currcolor}
        docker exec $oldname stop.sh || true
        docker stop $oldname || true
    else
        echo matar o velho - not today
    fi
}

# globals
set -e
canonized_app=${app/\//_}
dockerdata=$HOME/dockerdata/${app}_${environ}
resolvecolors "$app" "$environ"
nextname=${canonized_app}_${environ}_${nextcolor}
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
