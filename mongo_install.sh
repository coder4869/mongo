#This file provides mongodb auto-installing and auto-configuring opreations with shell commands
#const var Definations
MONGO_HOME=~/Desktop/mongodb3.2
MONGO_PORT=10002
MONGO_TEMP=~/Desktop/mongo.tmp

echo "#### downloading mongodb3.2.6 to Desktop ####"
curl -O https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.2.6.tgz ~/Desktop/

echo "#### unzip mongodb-linux-x86_64-3.2.6.tgz to mongodb3.2.6 ####"
mkdir -p ${MONGO_TEMP} # not MONGO_HOME dir
tar -zxvf ~/Desktop/mongodb-linux-x86_64-3.2.6.tgz -C ${MONGO_TEMP}

#Mongodb install dir
echo "#### Mongodb install dir: MONGO_HOME = "${MONGO_HOME}" ####"

echo "#### copy mongodb3.2.6 to destination dir ####"
mkdir -p ${MONGO_HOME}
cp -rf ${MONGO_TEMP}/mongodb-linux-x86_64-3.2.6/* ${MONGO_HOME}

echo "#### create default db data and log files ####"
mkdir -p ${MONGO_HOME}/data/db
mkdir -p ${MONGO_HOME}/log
touch ${MONGO_HOME}/log/mongodb.log
echo "" > ${MONGO_HOME}/mongodb.conf

echo "#### make default setting for mongodb.conf ####"
chmod 777 ${MONGO_HOME}/mongodb.conf
(
cat <<EOF
port=${MONGO_PORT}
dbpath=${MONGO_HOME}/data/db  #absolute path
logpath=${MONGO_HOME}/log/mongodb.log #absolute path
#master=true
fork=true #run background as daemon
maxConns=3000 #https://github.com/coder4869/mongo/wiki/Mongo-Start
oplogSize=2048 #similar to mysql’s log scroll，unit is MB
EOF
) >> ${MONGO_HOME}/mongodb.conf

echo "#### start mongodb ####"
mongod -f ${MONGO_HOME}/mongodb.conf

echo "#### link mongodb ####"
echo "mongo "localhost:${MONGO_PORT}

echo "#### Cleaning temp files ####"
rm -rf ${MONGO_TEMP}

echo "#### Mongo Running Status ####"
ps -ef|grep mongo

echo "###### For More: https://github.com/coder4869/mongo/wiki ######"
