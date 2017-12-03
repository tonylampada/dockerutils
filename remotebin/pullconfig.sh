#!/bin/bash
app=$1
environ=$2

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

scp -i ~/.ssh/cfgstore.pem -r  "$CFGSTORE_HOST:configstore/${app}_${environ}/*" ~/
echo "pullconfig baixou configuracoes de $CFGSTORE_HOST:configstore/${app}_${environ}"
