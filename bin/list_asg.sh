#!/bin/bash
asg=$1
if [ ! "$AWS_PROFILE" ]; then
    AWS_PROFILE=default
fi
instanceids=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $asg --query 'AutoScalingGroups[*].Instances[*].InstanceId' --output text --profile $AWS_PROFILE)
if [ -z "$instanceids" ]; then
    exit
fi
hostnames=$(aws ec2 describe-instances --instance-ids $instanceids --query='Reservations[*].Instances[*].PublicDnsName' --output text --profile $AWS_PROFILE)
for host in $hostnames; do
    echo ubuntu@$host
done
