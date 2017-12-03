#!/bin/bash
app=$1
version=$2
environ=$3

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

set -e
dkpull $app $version $environ
$SCRIPTPATH/pullconfig.sh $app $environ