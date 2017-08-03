#!/bin/bash
host=$1

ssh -o StrictHostKeyChecking=no $host mkdir -p dockerutils
rsync -av /opt/dockerutils/remotebin $host:./dockerutils/
rsync -av ~/.dockerutils $host:./
