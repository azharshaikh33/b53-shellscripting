#!/bin/bash

# set -e

COMPONENT=mysql
source components/common.sh

echo -n "Configuring the $COMPONENT repo:" &>> $LOGFILE
dnf module disable mysql -y &>> $LOGFILE
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo
stat $?

echo -n "Installing the $COMPONENT:"
dnf install mysql-community-server -y &>> $LOGFILE
stat $?

echo -n "STarting $COMPONENT:"
systemctl enable mysqld &>> $LOGFILE
systemctl start mysqld  &>> $LOGFILE
stat $?