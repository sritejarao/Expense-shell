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
    echo "To install mysql user should have root access"
    exit 1
else 
    echo "This user can only install mysql service"
fi

dnf list installed mysql
if [ $? -ne 0 ]; then
    echo "mysql is not installed, started installing"
    dnf install mysql-server -y &>>$LOGFILENAME
    VALIDATE $? "Mysql"
fi
systemctl enable mysqld &>>$LOGFILENAME
VALIDATE $? "Mysql is enabled"

systemctl start mysqld &>>$LOGFILENAME
VALIDATE $? "Mysql is started"


mysql -h mysql.learnnewthings.site -u root -pExpenseApp@1 -e 'show databases;' &>>$LOGFILENAME
if [ $? -ne 0 ]; then 
    echo "adding user to the mysql"
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILENAME
    VALIDATE $? "Mysql User is mapped"
fi


mysql -h mysql.learnnewthings.site -u root -pExpenseApp@1 -e 'show databases;' &>>$LOGFILENAME
VALIDATE $? "Mysql Up and running"