#!/bin/bash
app=$1
version=$2
environ=$3


function resolve_target_hosts {
    if [ "aws_asg" == "$DEPLOY_TARGET_TYPE" ]; then
        if [ ! "$AWS_PROFILE" ]; then
            AWS_PROFILE=default
        fi
        instanceids=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG --query 'AutoScalingGroups[*].Instances[*].InstanceId' --output text --profile $AWS_PROFILE)
        hostnames=$(aws ec2 describe-instances --instance-ids $instanceids --query='Reservations[*].Instances[*].PublicDnsName' --output text --profile $AWS_PROFILE)
        for host in $hostnames; do
            echo ubuntu@$host
        done
    else
        echo $HOST
    fi
}

if [ -f ~/.dockerutils/env.sh ]; then
    source ~/.dockerutils/env.sh
fi
hosts=$(resolve_target_hosts)
if [ "$hosts" ]; then
    echo "[BLUEGREEN] hosts pra deploy: $hosts"
    for host in $hosts; do
        install_dockerutils_remote.sh $host
        ssh -o StrictHostKeyChecking=no $host dockerutils/remotebin/bluegreen.sh $app $version $environ
        echo "[BLUEGREEN] deploy feito no host $host"
    done
fi
