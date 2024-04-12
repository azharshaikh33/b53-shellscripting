#!/bin/bash

# set -e

COMPONENT=redis
source components/common.sh
# LOGFILE="/tmp/$COMPONENT.log"


# ID=$(id -u)

# if [ "$ID" -ne 0 ] ; then
#     echo -e "\e[31m You should execute this script as a root user or with a sudo as a prefix \e[0m"
#     exit 1
# fi    

# stat() {
#     if [ $1 -eq 0 ] ; then
#         echo -e "\e[32m Success \e[0m"
#     else
#         echo -e "\e[31m Failure \e[0m"
#         exit 2
#     fi
# }

echo -n "Installing $COMPONENT repo:"
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
stat $?

echo -n "Enabling $COMPONENT 6.2:"
dnf module enable redis:remi-6.2 -y &>> $LOGFILE
stat $?

echo -n "Installing $COMPONENT:"
dnf install redis -y &>> $LOGFILE
stat $?

echo -n "Updating the $COMPONENT visibility:"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
stat $?

echo -n "Performing Daemon-Reload:"
systemctl daemon-reload &>> $LOGFILE
systemctl enable $COMPONENT &>> $LOGFILE
systemctl restart $COMPONENT &>> $LOGFILE
stat $?


