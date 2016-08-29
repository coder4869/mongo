#!/bin/bash
#This file provides mongodb master-slave config settig with shell commands
#The configures relates to mongo_install.sh (https://github.com/coder4869/mongo/blob/master/mongo_install.sh) 
#const var Definations
MONGO_HOME=~/Desktop/mongodb3.2 #the same as mongo_install.sh
DB_HOME=~/Desktop/mongodb3.2
MASTER_HOME=${DB_HOME}/master
SLAVE0_HOME=${DB_HOME}/slave0
MASTER_PORT=10003
SLAVE0_PORT=10004
DB_TEMP=~/Desktop/mongo.tmp

#kill process with port 10002
kill -9 $(lsof -i:10002|tail -1|awk '"$1"!=""{print $2}')

echo "#### remove default mongodb setting ####"
rm -rf ${MONGO_HOME}/data
rm -rf ${MONGO_HOME}/log
rm ${MONGO_HOME}/mongodb.conf

#############################################################
sudo mkdir -p ${MASTER_HOME}
sudo chmod 777 ${MASTER_HOME}
echo "#### make master config ####"
mkdir -p ${MASTER_HOME}/data/db
mkdir -p ${MASTER_HOME}/log
sudo touch ${MASTER_HOME}/log/mongodb.log
echo "" > ${MASTER_HOME}/mongodb.conf

echo "#### make default setting for mongodb.conf ####"
chmod 777 ${MASTER_HOME}/mongodb.conf
(
cat <<EOF
port=${MASTER_PORT}
dbpath=${MASTER_HOME}/data/db  #absolute path
logpath=${MASTER_HOME}/log/mongodb.log #absolute path
master=true
fork=true #run background as daemon
maxConns=3000 #https://github.com/coder4869/mongo/wiki/Mongo-Start
oplogSize=2048 #similar to mysql’s log scroll，unit is MB
EOF
) >> ${MASTER_HOME}/mongodb.conf
echo "#### master starting ####"
mongod -f ${MASTER_HOME}/mongodb.conf

#############################################################
echo "#### make slave0 config ####"
sudo mkdir -p ${SLAVE0_HOME}
sudo chmod 777 ${SLAVE0_HOME}
mkdir -p ${SLAVE0_HOME}/data/db
mkdir -p ${SLAVE0_HOME}/log
sudo touch ${SLAVE0_HOME}/log/mongodb.log
echo "" > ${SLAVE0_HOME}/mongodb.conf

echo "#### make default setting for mongodb.conf ####"
chmod 777 ${SLAVE0_HOME}/mongodb.conf
(
cat <<EOF
port=${SLAVE0_PORT}
dbpath=${SLAVE0_HOME}/data/db  #absolute path
logpath=${SLAVE0_HOME}/log/mongodb.log #absolute path
slave=true
source=127.0.0.1:${MASTER_PORT}
slavedelay=10  #time differ for delaying copy from master, backup once for each 10s
autoresync=true  #if data not latest, send sync request to master server
fork=true #run background as daemon
maxConns=3000 #https://github.com/coder4869/mongo/wiki/Mongo-Start
oplogSize=2048 #similar to mysql’s log scroll，unit is MB
EOF
) >> ${SLAVE0_HOME}/mongodb.conf
echo "#### slave0 starting ####"
mongod -f ${SLAVE0_HOME}/mongodb.conf

#############################################################

echo "#### Mongo Running Status ####"
ps -ef|grep mongo

