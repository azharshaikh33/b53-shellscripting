#!/bin/bash

#This is script to launch EC2 servers and create the associated Route53 Record.

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-Centos-8" | jq '.Images[].ImageId' | sed -e 's/"//g')
echo "AMI ID is $AMI_ID"