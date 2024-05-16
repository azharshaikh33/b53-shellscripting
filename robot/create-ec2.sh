#!/bin/bash

#This is script to launch EC2 servers and create the associated Route53 Record.


if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "\e[31m Component Name is required \e[0m"
    echo -e "\t\t \e[32m Sample usage is: $ bash create-ec2.sh user dev \e[0m "
    exit 1

fi

HOSTEDZONEID="Z093296193U6R55S5C7L"
COMPONENT=$1
ENV=$2

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-Centos-8" | jq '.Images[].ImageId' | sed -e 's/"//g')
SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=b53-allow-all-sg | jq '.SecurityGroups[].GroupId' | sed -e 's/"//g')

echo Ami ID is $AMI_ID

echo -n "Launching the Instance with $AMI_ID as AMI :"

create_server() {

echo "*** Launching $COMPONENT Server ***"

IPADDRESS=$(aws ec2 run-instances --image-id ${AMI_ID} \
                      --instance-type t2.micro \
                      --security-group-ids ${SGID} \
                      --instance-market-options "MarketType=spot, SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=Stop}" \
                      --tag-specifications "ResourceType=instance,Tags=[{Key=name,Value=$COMPONENT-$ENV}]" | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

sed -e "s/COMPONENT/${COMPONENT}-${ENV}/" -e "s/IPADDRESS/${IPADDRESS}/" record.json > /tmp/record.json
aws route53 change-resource-record-sets --hosted-zone-id $HOSTEDZONEID --change-batch file:///tmp/record.json | jq

echo "*** Launching $COMPONENT Server completed ***"

}

if [ "$1" == "all" ] ; then
    for component in frontend mongodb catalogue cart user mysql redis rabbitmq shipping payment ; do
        COMPONENT=$component
        create_server
    done

else
        create_server

fi
