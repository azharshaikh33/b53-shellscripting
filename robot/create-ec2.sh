#!/bin/bash

#This is script to launch EC2 servers and create the associated Route53 Record.

COMPONENT=$1

if [ -z "$1" ]; then
    echo -e "\e[31m Component Name is required \e[0m"
    echo -e "\t\t \e[32m Sample usage is: $ bash create-ec2.sh user \e[0m "
    exit 1

fi

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-Centos-8" | jq '.Images[].ImageId' | sed -e 's/"//g')
echo "AMI ID is $AMI_ID"

echo -n "Launching the Instance with $AMI_ID as AMI:"
aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --tag-specifications "ResourceType=instance,Tags=[{Key=name,Value=$COMPONENT}]"
stat $?