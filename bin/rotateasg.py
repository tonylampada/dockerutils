#!/usr/bin/python

from time import sleep
import argparse
import boto3
import sys

asgname, region, tgarn = None, None, None
asgcli, elbcli = None, None

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--asg', required=True, help='AutoScaleGroup name')
    parser.add_argument('--region', required=True, help='AWS region (ex: us-east-2)')
    args = parser.parse_args()
    global asgname, region
    asgname, region = args.asg, args.region
    print(asgname, region)
    rotate()


def rotate():
    global asgcli, elbcli, tgarn
    asgcli = boto3.client('autoscaling', region_name=region)
    elbcli = boto3.client('elbv2', region_name=region)
    asg = getasg()
    tgarn = getTargetGroupARN()
    minsize, desired, maxsize = asg['MinSize'], asg['DesiredCapacity'], asg['MaxSize']
    print('ASG starting with min=%s, desired=%s, max=%s' % (minsize, desired, maxsize))
    old_ids = getOldInstanceIds(asg)
    print('Lets scale UP')
    setSize(2 * desired, 2 * desired, 2 * desired, True)
    waitTrue(3, 600, _newup(old_ids=old_ids, desiredlen=desired))
    print('Lets scale DOWN')
    setSize(desired, desired, desired)
    waitTrue(3, 600, _olddown(old_ids=old_ids))
    print('Restoring bounds')
    setSize(minsize, desired, maxsize)
    unprotect()


def getasg():
    return asgcli.describe_auto_scaling_groups(AutoScalingGroupNames=[asgname])['AutoScalingGroups'][0]

def getTargetGroupARN():
    return asgcli.describe_load_balancer_target_groups(AutoScalingGroupName=asgname)['LoadBalancerTargetGroups'][0]['LoadBalancerTargetGroupARN']

def getOldInstanceIds(asg):
    return {i['InstanceId'] for i in asg['Instances']}


def setSize(minsize, desired, maxsize, protectScaleIn=False):
    asgcli.update_auto_scaling_group(AutoScalingGroupName=asgname, MinSize=minsize, DesiredCapacity=desired, MaxSize=maxsize, NewInstancesProtectedFromScaleIn=protectScaleIn)
    print('resizing ASG: min=%s, desired=%s, max=%s' % (minsize, desired, maxsize))


def waitTrue(interval, timeout, func):
    keepgoing = True
    timespent = 0
    while True:
        if func():
            return
        sleep(interval)
        timespent += interval
        print('wating %s...' % timespent)
        if timespent > timeout:
            print('Timeout reached. Aborting')
            exit(1)


def unprotect():
    asg = getasg()
    instanceIds = [i['InstanceId'] for i in asg['Instances']]
    asgcli.set_instance_protection(InstanceIds=instanceIds, AutoScalingGroupName=asgname, ProtectedFromScaleIn=False)


def _newup(old_ids, desiredlen):
    def f():
        ths = elbcli.describe_target_health(TargetGroupArn=tgarn)['TargetHealthDescriptions']
        ths = [th for th in ths if th['Target']['Id'] not in old_ids]
        print(', '.join(['%s=%s' % (th['Target']['Id'], th['TargetHealth']['State']) for th in ths]))
        return len(ths) == desiredlen and all([th['TargetHealth']['State'] == 'healthy' for th in ths])
    return f


def _olddown(old_ids):
    def f():
        ths = elbcli.describe_target_health(TargetGroupArn=tgarn)['TargetHealthDescriptions']
        ths = [th for th in ths if th['Target']['Id'] in old_ids]
        print(', '.join(['%s=%s' % (th['Target']['Id'], th['TargetHealth']['State']) for th in ths]))
        return all([th['TargetHealth']['State'] != 'healthy' for th in ths])
    return f


if __name__ == '__main__':
    main()