#!/bin/bash
host=$1

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/common.sh

set -e
ssh -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $host mkdir -p dockerutils
rsync -e "ssh -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" -L -av $SCRIPTPATH/../remotebin $host:./dockerutils/
if [ -d ~/.dockerutils ]; then
    rsync -e "ssh -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" -av ~/.dockerutils $host:./
fi
