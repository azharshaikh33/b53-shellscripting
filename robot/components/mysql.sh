#!/bin/bash

# set -e

COMPONENT=mysql
source components/common.sh

echo -n "Configuring the $COMPONENT repo:"
dnf module disable mysql -y &>> $LOGFILE
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo
stat $?

echo -n "Installing the $COMPONENT:"
dnf install mysql-community-server -y &>> $LOGFILE
stat $?

echo -n "Starting $COMPONENT:"
systemctl enable mysqld &>> $LOGFILE
systemctl start mysqld  &>> $LOGFILE
stat $?

echo -n "Grab $COMPONENT default password:"
DEFAULT_ROOT_PWD=$(grep "temporary password" /var/log/mysqld.log | awk '{print $NF}')
stat $?

echo "show databases;" | mysql -uroot -pRoboShop@1 &>> $LOGFILE
if [ $? -ne 0 ] ; then

    echo -n "Password reset of root user:"
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" | mysql --connect-expired-password -uroot -p${DEFAULT_ROOT_PWD} &>> $LOGFILE
    stat $?

fi

echo "show plugins;" | mysql -uroot -pRoboShop@1 | grep validate_password &>> $LOGFILE
if [ $? -eq 0 ] ; then

    echo -n "uninstalling password validation plugin:"
    echo "uninstall plugin validate_password;" | mysql -uroot -pRoboShop@1 &>> $LOGFILE
    stat $?

fi

echo -n "Downloading the $COMPONENT Schema:"
curl -s -L -o /tmp/mysql.zip "https://github.com/stans-robot-project/mysql/archive/main.zip"
stat $?

echo -n "Extracting the $COMPONENT Schema:"
cd /tmp
unzip -o /tmp/$COMPONENT.zip &>> $LOGFILE
stat $?

echo -n "Injecting the schema:"
mysql -u root -pRoboShop@1 <shipping.sql &>> $LOGFILE
stat $?

