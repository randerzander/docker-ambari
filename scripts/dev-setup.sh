#!/bin/bash
cp /scripts/bashrc /root/.bashrc
cp /scripts/vimrc /root/.vimrc

yum install -y git vim apache-maven

# Python packages
#yum install lapack-devel gcc-c++
#wget https://bootstrap.pypa.io/get-pip.py
#python get-pip.py
#pip install numpy
#pip install scipy
