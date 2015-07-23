#!/bin/bash

while [ -z "$(netstat -tulpn | grep 8080)" ]; do
  ambari-server start
  ambari-agent start
  sleep 20
done

while true; do
  #start SERVICES
  sleep 3
  tail -f /var/log/ambari-server/ambari-server.log
done
