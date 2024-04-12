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

CREATE_USER() {

    id $APPUSER &>> $LOGFILE
    if [ $? -ne 0 ] ; then
        echo -n "Creating application user account:"
        useradd roboshop &>> $LOGFILE
        stat $?
    fi

}


DOWNLOAD_AND_EXTRACT() {

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

}

NPM_INSTALL() {

    echo -n "installing the $COMPONENT application:"
    cd /home/$APPUSER/$COMPONENT
    npm install &>> $LOGFILE
    stat $?

}

CONFIG_SVC() {

    echo -n "Updating the systemd files with DB details:"
    sed -i -e 's/AMQPHOST/rabbitmq.azharpro.internal/' -e 's/USERHOST/user.azharpro.internal/' -e 's/CARTHOST/CART.azharpro.internal/' -e 's/DBHOST/mysql.azharpro.internal/' -e 's/CARTENDPOINT/cart.azharpro.internal/' -e 's/REDIS_ENDPOINT/redis.azharpro.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.azharpro.internal/' -e 's/MONGO_DNSNAME/mongodb.azharpro.internal/' -e 's/REDIS_ENDPOINT/redis.azharpro.internal/' -e 's/MONGO_ENDPOINT/mongodb.azharpro.internal/' /home/$APPUSER/$COMPONENT/systemd.service
    mv /home/$APPUSER/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
    stat $?

    echo -n "Starting the service:"
    systemctl daemon-reload
    systemctl enable $COMPONENT &>> $LOGFILE
    systemctl start $COMPONENT &>> $LOGFILE
    stat $?
}

MVN_PACKAGE() {
    echo -n "installing the $COMPONENT package:"
    cd /home/$APPUSER/$COMPONENT
    mvn clean package &>> $LOGFILE
    mv target/shipping-1.0.jar shipping.jar
    stat $?
}

PYTHON () {
    echo -n "Installing Maven:"
    dnf install python36 gcc python3-devel -y &>> $LOGFILE
    stat $?

    CREATE_USER

    DOWNLOAD_AND_EXTRACT

    echo -n "Installing $COMPONENT:"
    cd /home/$APPUSER/$COMPONENT 
    pip3.6 install -r requirements.txt &>> $LOGFILE
    stat $?

    USERID=$(id -u roboshop)
    GROUPID=$(id -g roboshop)

    echo -n "updating the $COMPONENT:"
    sed -e "/^uid/ c uid=$USERID" -e "/^gid/ c gid=$GROUPID" /home/$APPUSER/$COMPONENT/$COMPONENT.ini

    CONFIG_SVC

}

JAVA () {
    echo -n "Installing maven:"
    dnf install maven -y &>> $LOGFILE
    $?

    CREATE_USER

    DOWNLOAD_AND_EXTRACT

    MVN_PACKAGE

    CONFIG_SVC
}

NODEJS() {

    echo -n "Disabling the default nodejs:10 repo and enabling nodejs18:"
    dnf module disable nodejs -y &>> $LOGFILE
    dnf module enable nodejs:18 -y &>> $LOGFILE
    stat $?

    echo -n "Installing NodeJS:"
    dnf install nodejs -y &>> $LOGFILE
    stat $?

    CREATE_USER

    DOWNLOAD_AND_EXTRACT

    NPM_INSTALL

    CONFIG_SVC
}