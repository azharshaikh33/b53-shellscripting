#!/bin/bash

#This is script to launch EC2 servers and create the associated Route53 Record.

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-Centos-8" | jq '.Images[].ImageId' | sed -e 's/"//g')
echo "AMI ID is $AMI_ID"

echo -n "Launching the Instance with $AMI_ID as AMI:"
aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro