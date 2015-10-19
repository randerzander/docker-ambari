#!/bin/bash
cp /scripts/bashrc /root/.bashrc
source ~/.bashrc
cp /scripts/vimrc /root/.vimrc

MAVEN_VER=3.3.3
wget http://mirror.symnds.com/software/Apache/maven/maven-3/$MAVEN_VER/binaries/apache-maven-$MAVEN_VER-bin.tar.gz
tar -xzvf apache-maven-$MAVEN_VER-bin.tar.gz
echo "export PATH=$PATH:/apache-maven-$MAVEN_VER/bin" >> ~/.bashrc
echo "export SPARK_HOME=/usr/hdp/current/spark-client" >> ~/.bashrc

yum install -y git vim

# Python packages
yum install lapack-devel gcc-c++
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
#pip install numpy
#pip install scipy
