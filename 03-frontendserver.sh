#!/bin/bash

USER=$(id -u)

LOG_FILE=$(echo $0 | cut -d "." -f1 )
day=$(date +%y-%m-%d)
TIME_STAMP=$(date +%y-%m-%d-%H-%M-%S)
PATH1="/var/log/script_logs"
LOGFILENAME="$PATH1/$LOG_FILE-$day.log"


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
    echo "To install frontend service, user should have root access"
    exit 1
else 
    echo "This user can only install frontend service"
    mkdir -p $PATH1

fi

dnf list installed nginx &>>$LOGFILENAME
if [ $? -ne 0 ]; then
    echo "nginx not installed, nginx installtion stared"
    dnf install nginx -y  &>>$LOGFILENAME
    VALIDATE $? "nginx"
else
    echo "nginx is already installed"

fi
systemctl enable nginx  &>>$LOGFILENAME
VALIDATE $? "nginx enable"

systemctl start nginx  &>>$LOGFILENAME
VALIDATE $? "nginx start"

rm -rf /usr/share/nginx/html/*  &>>$LOGFILENAME
VALIDATE $? "Removing old nginx files"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip  &>>$LOGFILENAME
VALIDATE $? "Downloading frontend setUp"

cd /usr/share/nginx/html  &>>$LOGFILENAME
VALIDATE $? "Naviagting to html folder"

unzip /tmp/frontend.zip  &>>$LOGFILENAME
VALIDATE $? "Unzipping the frontend setUp"


cp /home/ec2-user/expense.conf /etc/nginx/default.d/expense.conf  &>>$LOGFILENAME
VALIDATE $? "expence.conf placed"

systemctl restart nginx  &>>$LOGFILENAME
VALIDATE $? "nginx resart"