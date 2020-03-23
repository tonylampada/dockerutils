#!/bin/bash
tsg_arn=$1
if [ ! "$AWS_PROFILE" ]; then
    AWS_PROFILE=default
fi
instanceids=$(aws elbv2 describe-target-health --target-group-arn $tsg_arn --query 'TargetHealthDescriptions[*].Target.Id' --output text --profile $AWS_PROFILE)
if [ -z "$instanceids" ]; then
    exit
fi
hostnames=$(aws ec2 describe-instances --instance-ids $instanceids --query='Reservations[*].Instances[*].PublicDnsName' --filters='Name=instance-state-name,Values=running' --output text --profile $AWS_PROFILE)
for host in $hostnames; do
    echo ubuntu@$host
done
