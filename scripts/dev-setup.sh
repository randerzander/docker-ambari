#!/bin/bash
cp /scripts/bashrc /root/.bashrc
cp /scripts/vimrc /root/.vimrc

yum install -y git vim apache-maven lapack-devel gcc-c++
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install numpy
pip install scipy

#Spark 1.4.1 with HDP 2.3.0
wget https://gist.github.com/randerzander/cbcf30f2db67d9a6fd57/raw/a85b5403d8150918ea6ff9695760dc8eeada5ff8/spark-1.4.1-setup.sh
sh spark-1.4.1-setup.sh

#Build latest Zeppelin
wget https://gist.github.com/randerzander/5c6ca7bdd06876c9b247/raw/ae26dcc877a8bd5c93a428bcac5507a378d3c151/zeppelin-setup.sh
sh zeppelin-setup.sh
