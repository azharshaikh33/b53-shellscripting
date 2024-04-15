#!/bin/bash

#This is script to launch EC2 servers and create the associated Route53 Record.


if [ -z "$1" ]; then
    echo -e "\e[31m Component Name is required \e[0m"
    echo -e "\t\t \e[32m Sample usage is: $ bash create-ec2.sh user \e[0m "
    exit 1

fi

HOSTEDZONEID="Z093296193U6R55S5C7L"
COMPONENT=$1

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-Centos-8" | jq '.Images[].ImageId' | sed -e 's/"//g')
SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=b53-allow-all-sg | jq '.SecurityGroups[].GroupId' | sed -e 's/"//g')

echo Ami ID is $AMI_ID

echo -n "Launching the Instance with $AMI_ID as AMI :"
IPADDRESS=$(aws ec2 run-instances --image-id ${AMI_ID} \
                      --instance-type t2.micro \
                      --security-group-ids ${SGID} \
                      --instance-market-options "MarketType=spot, SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=Stop}" \
                      --tag-specifications "ResourceType=instance,Tags=[{Key=name,Value=$COMPONENT}]" | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

sed -e "s/COMPONENT/${COMPONENT}/" -e "s/IPADDRESS/${IPADDRESS}/" robot/record.json > /tmp/r53.json
aws route53 change-resource-record-sets --hosted-zone-id $HOSTEDZONEID --change-batch file:///tmp/r53.json