#!/bin/bash

# set -e

COMPONENT=frontend
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

echo -n "Installing Nginx : "
dnf install nginx -y &>> $LOGFILE
stat $?

echo -n "Downloading the $COMPONENT content : "
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
stat $?

echo -n "Performing cleanup old $COMPONENT content : "
cd /usr/share/nginx/html
rm -rf * &>> $LOGFILE
stat $?

echo -n "Copying the downloaded $COMPONENT content: "
unzip /tmp/$COMPONENT.zip &>> $LOGFILE
mv $COMPONENT-main/* .
mv static/* .
rm -rf $COMPONENT-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf
stat $?

for component in catalogue cart user shipping payment; do
    echo -n "Updating the proxy details in the reverse proxy file:"
    sed -i "/$COMPONENT/s/localhost/$COMPONENT.azharpro.internal/" /etc/nginx/default.d/roboshop.conf
done

echo -n "Starting the service: "
systemctl enable nginx &>> $LOGFILE
systemctl restart nginx &>> $LOGFILE
stat $?

# curl -s -L -o /tmp/frontend.zip "https://github.com/stans-robot-project/frontend/archive/main.zip"

# cd /usr/share/nginx/html
# rm -rf *
# unzip /tmp/frontend.zip
# mv frontend-main/* .
# mv static/* .
# rm -rf frontend-main README.md
# mv localhost.conf /etc/nginx/default.d/roboshop.conf

# Restart Nginx
