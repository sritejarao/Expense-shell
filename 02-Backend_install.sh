#!/bin/bash

USER=$(id -u)

LOG_FILE=$(echo $0 | cut -d "." -f1 )
day=$(date +%y-%m-%d)
TIME_STAMP=$(date +%y-%m-%d-%H-%M-%S)
PATH1="/var/log/script_logs"
LOGFILENAME="$PATH1/$LOG_FILE-$day.log"
mkdir -p $PATH1

VALIDATE()
{
    if [ $? -ne 0 ]; then
        echo "$2 ..... Failure"
        exit 1
    else
        echo " $2 ....... Success"
    fi
}

if [ $USER -ne 0 ]; then
    echo "To install mysql user should have root access"
    exit 1
else 
    echo "This user can only install mysql service"
fi


dnf module disable nodejs -y &>>$LOGFILENAME
VALIDATE $? "nodejs disable"

dnf module enable nodejs:20 -y  &>>$LOGFILENAME
VALIDATE $? "nodejs:20 enable"

dnf install nodejs -y  &>>$LOGFILENAME
VALIDATE $? "nodejs instaled"

id expense
if [ $? -ne 0 ]; then
    useradd expense  &>>$LOGFILENAME
    VALIDATE $? "expense user added"
else
    echo "expense user already present"
fi

cd /app  &>>$LOGFILENAME
if [ $? -ne 0 ]
then
    mkdir -p /app
    VALIDATE $? "app directory created"
else
    echo "app directory already present"
fi

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOGFILENAME
VALIDATE $? "download"

cd /app
VALIDATE $? "directory access"

rm -rf *  &>>$LOGFILENAME
VALIDATE $? "Old files removed"

unzip /tmp/backend.zip  &>>$LOGFILENAME
VALIDATE $? "Unzipping backend service"

dnf list installed npm   &>>$LOGFILENAME
if [ $? -ne 0 ]; then
    echo "npm install started"
    dnf install npm -y  &>>$LOGFILENAME
    if [ $? -ne 0 ]; then
        VALIDATE $? "npm install"
    else
        VALIDATE $? "npm install"
    fi
else
    echo "npm already installed"
fi

cp /home/ec2-user/backend.service /etc/systemd/system/backend.service  &>>$LOGFILENAME
ll /etc/systemd/system/backend.service  &>>$LOGFILENAME
VALIDATE $? "backend.service "

systemctl daemon-reload  &>>$LOGFILENAME
VALIDATE $? "daemon-reload"

systemctl start backend  &>>$LOGFILENAME
VALIDATE $? "Backend started"

systemctl enable backend  &>>$LOGFILENAME
VALIDATE $? "Backend enabled"

dnf list installed mysql  &>>$LOGFILENAME
if [ $? -ne 0 ]; then
    dnf install mysql -y  &>>$LOGFILENAME
    VALIDATE $? "MySql install"
else
    echo "Mysql already installed"
fi
mysql -h mysql.learnnewthings.site -uroot -pExpenseApp@1 < /app/schema/backend.sql  &>>$LOGFILENAME
VALIDATE $? "backend.sql loading"

systemctl restart backend  &>>$LOGFILENAME
VALIDATE $? "backend restart"