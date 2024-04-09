#!/bin/bash

# set -e

COMPONENT=catalogue
LOGFILE="/tmp/$COMPONENT.log"

ID=$(id -u)

if [ "$ID" -ne 0 ] ; then
    echo -e "\e[31m You should execute this script as a root user or with a sudo as a prefix \e[0m"
    exit 1
fi    

stat() {
    if [ $1 -eq 0 ] ; then
        echo -e "\e[32m Success \e[0m"
    else
        echo -e "\e[31m Failure \e[0m"
        exit 2
    fi
}

echo -n "Disabling the default nodejs:10 repo and enabling nodejs18:"
dnf module disable nodejs -y &>> $LOGFILE
dnf module enable nodejs:18 -y &>> $LOGFILE
stat $?

echo -n "Installing NodeJS:"
dnf install nodejs -y &>> $LOGFILE
stat $?

echo -n "Creating application user account:"
useradd roboshop &>> $LOGFILE
stat $?

echo -n "Downloading the $COMPONENT component:"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
stat $?

echo -n "extracting the $COMPONENT in the $APPUSER directory"
cd /home/$APPUSER
unzip /tmp/$COMPONENT.zip &>> $LOGFILE