#!/bin/bash
host=$1

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

set -e
ssh -o StrictHostKeyChecking=no $host mkdir -p dockerutils
rsync -L -av $SCRIPTPATH/remotebin $host:./dockerutils/
if [ -d ~/.dockerutils ]; then
    rsync -av ~/.dockerutils $host:./
fi
