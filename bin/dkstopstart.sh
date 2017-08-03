#!/bin/bash
app=$1
version=$2
environ=$3
service=$4

function dynamicvar {
    v=$1
    echo ${!v}
}

function resolve_target_hosts {
    targettype=$(dynamicvar ${service}_DEPLOY_TARGET_TYPE)
    if [ "aws_asg" == "$targettype" ]; then
        if [ ! "$AWS_PROFILE" ]; then
            AWS_PROFILE=default
        fi
        asgname=$(dynamicvar ${service}_ASG)
        instanceids=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $asgname --query 'AutoScalingGroups[*].Instances[*].InstanceId' --output text --profile $AWS_PROFILE)
        hostnames=$(aws ec2 describe-instances --instance-ids $instanceids --query='Reservations[*].Instances[*].PublicDnsName' --output text --profile $AWS_PROFILE)
        for host in $hostnames; do
            echo ubuntu@$host
        done
    elif [ "host" == "$targettype" ]; then
        host=$(dynamicvar ${service}_HOST)
        echo $host
    else
        echo ""
    fi
}

DKU="$(dirname ${BASH_SOURCE[0]})/.."
source $DKU/envs/${app}_${environ}.env
hosts=$(resolve_target_hosts)
if [ "$hosts" ]; then
    echo "[STOPSTART] hosts pra iniciar $service: $hosts"
    for host in $hosts; do
        install_dockerutils_remote.sh $host
        cmd=$(dynamicvar ${service}_CMD)
        ssh -o StrictHostKeyChecking=no $host dockerutils/remotebin/stopstart.sh $app $version $environ $service "$cmd"
        echo "[STOPSTART] $service iniciado no host $host"
    done
fi
