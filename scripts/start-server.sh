#!/bin/bash

source /control.sh

while [ -z "$(netstat -tulpn | grep 8080)" ]; do
  cd /usr/jdk64/jdk*/jre/lib/security/
  unzip /var/lib/ambari-server/resources/jce_policy-*
  ambari-server start
  ambari-agent start
  sleep 20
done

while true; do
  #start SERVICES
  sleep 3
  tail -f /var/log/ambari-server/ambari-server.log
done
