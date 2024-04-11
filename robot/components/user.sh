#!/bin/bash

# set -e

COMPONENT=user
LOGFILE="/tmp/$COMPONENT.log"
APPUSER=roboshop

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

id $APPUSER &>> $LOGFILE
if [ $? -ne 0 ] ; then
    echo -n "Creating application user account:"
    useradd roboshop &>> $LOGFILE
    stat $?
fi

echo -n "Downloading the $COMPONENT component:"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
stat $?

echo -n "extracting the $COMPONENT in the $APPUSER directory"
cd /home/$APPUSER
rm -rf /home/$APPUSER/$COMPONENT &>> $LOGFILE
unzip -o /tmp/$COMPONENT.zip &>> $LOGFILE
stat $?

echo -n "configuring the permission:"
mv /home/$APPUSER/$COMPONENT-main /home/$APPUSER/$COMPONENT
chown -R $APPUSER:$APPUSER /home/$APPUSER/$COMPONENT
stat $?

echo -n "installing the $COMPONENT application:"
cd /home/$APPUSER/$COMPONENT
npm install &>> $LOGFILE
stat $?

echo -n "Updating the systemd files with DB details:"
sed -i -e 's/REDIS_ENDPOINT/mongodb.azharpro.internal/' -e 's/MONGO_ENDPOINT/mongodb.azharpro.internal/' /home/$APPUSER/$COMPONENT/systemd.service
mv /home/$APPUSER/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
stat $?

echo -n "Starting the service:"
systemctl daemon-reload
systemctl enable $COMPONENT &>> $LOGFILE
systemctl start $COMPONENT &>> $LOGFILE
stat $?