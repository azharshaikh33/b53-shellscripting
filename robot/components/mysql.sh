#!/bin/bash

# set -e

COMPONENT=mysql
source components/common.sh

echo -n "Configuring the $COMPONENT repo:"
dnf module disable mysql -y 
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo
stat $?

echo -n "Installing the $COMPONENT:"
dnf install mysql-community-server -y
stat $?

echo -n "STarting $COMPONENT:"
systemctl enable mysqld 
systemctl start mysqld
stat $?