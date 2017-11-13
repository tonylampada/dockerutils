#!/bin/bash
host=$1

ssh -o StrictHostKeyChecking=no $host mkdir -p dockerutils
rsync -L -av /opt/dockerutils/remotebin $host:./dockerutils/
if [ -d ~/.dockerutils ]; then
    rsync -av ~/.dockerutils $host:./
fi
