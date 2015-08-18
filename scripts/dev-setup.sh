#!/bin/bash
yum install -y git vim apache-maven
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
#pip install numpy scipy

#Spark 1.4.1 with HDP 2.3.0
git clone https://github.com/apache/incubator-zeppelin
cd incubator-zeppelin
#mvn clean package -DskipTests -Dspark.version=1.4.1 -Dhadoop.version=2.7.1 -Pyarn -Phadoop-2.6 -Pspark-1.4 -Ppyspark 

# Configure Zeppelin JVM, App Master JVM, and Executor JVMs with hdp.version which 
HDP_VER=`hdp-select status hadoop-client| sed 's/hadoop-client - \(.*\)/\1/'`
echo Using hdp.version=$HDP_VER

cp conf/zeppelin-env.sh.template conf/zeppelin-env.sh
echo "export HADOOP_CONF_DIR=/etc/hadoop/conf" >> conf/zeppelin-env.sh
echo 'export ZEPPELIN_JAVA_OPTS="-Dhdp.version='$HDP_VER'"' >> conf/zeppelin-env.sh
#echo 'export ZEPPELIN_JAVA_OPTS="-Dhdp.version=2.3.0.0-2557"' >> conf/zeppelin-env.sh
# Change port to fix Ambari conflict
cp conf/zeppelin-site.xml.template conf/zeppelin-site.xml
sed -i "s/8080/8081/g" conf/zeppelin-site.xml
