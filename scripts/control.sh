USER='admin'
PASS='admin'
CLUSTER='dev'
HOST=$(hostname -f):8080

function start(){
  curl -u $USER:$PASS -i -H 'X-Requested-By: ambari' -X PUT -d \
    '{"RequestInfo": {"context" :"Start '"$1"' via REST"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}' \
    http://$HOST/api/v1/clusters/$CLUSTER/services/$1
}

function startWait(){
  curl -s -u $USER:$PASS -H 'X-Requested-By: ambari' -X PUT -d \
    '{"RequestInfo": {"context" :"Start '"$1"' via REST"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}' \
    http://$HOST/api/v1/clusters/$CLUSTER/services/$1
  wait $1 "STARTED"
}

function stop(){
  curl -u $USER:$PASS -i -H 'X-Requested-By: ambari' -X PUT -d \
    '{"RequestInfo": {"context" :"Stop '"$1"' via REST"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' \
    http://$HOST/api/v1/clusters/$CLUSTER/services/$1
}

function stopWait(){
  curl -s -u $USER:$PASS -H 'X-Requested-By: ambari' -X PUT -d \
    '{"RequestInfo": {"context" :"Stop '"$1"' via REST"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' \
    http://$HOST/api/v1/clusters/$CLUSTER/services/$1
  wait $1 "INSTALLED"
}

function maintOff(){
  curl -u $USER:$PASS -i -H 'X-Requested-By: ambari' -X PUT -d \
  '{"RequestInfo":{"context":"Turn Off Maintenance Mode"},"Body":{"ServiceInfo":{"maintenance_state":"OFF"}}}' \
  http://$HOST/api/v1/clusters/$CLUSTER/services/$1
}

function maintOn(){
  curl -u $USER:$PASS -i -H 'X-Requested-By: ambari' -X PUT -d \
  '{"RequestInfo":{"context":"Turn Off Maintenance Mode"},"Body":{"ServiceInfo":{"maintenance_state":"ON"}}}' \
  http://$HOST/api/v1/clusters/$CLUSTER/services/$1
}

function delete(){
  curl -u $USER:$PASS -i -H 'X-Requested-By: ambari' -X DELETE http://$HOST/api/v1/clusters/$CLUSTER/services/$1
}

function wait(){
  finished=0
  while [ $finished -ne 1 ]
  do
    str=$(curl -s -u $USER:$PASS http://{$HOST}/api/v1/clusters/$CLUSTER/services/$1)
    if [[ $str == *"$2"* ]] || [[ $str == *"Service not found"* ]] 
    then
      finished=1
    fi
    sleep 3
  done
}

function check() {
  str=$(curl -s -u $USER:$PASS http://{$HOST}/api/v1/clusters/$CLUSTER/services/$1)
  if [[ $str == *"$2"* ]]
  then
    echo 1
  else
    echo 0
  fi
}

function kerberos(){
  # Setup Kerberos
  export REALM=${HOST^^}
  cp /var/lib/ambari-server/resources/scripts/krb5.conf /etc/krb5.conf
  sed -i "s/EXAMPLE\.COM/$REALM/g" /etc/krb5.conf
  sed -i "s/kerberos\.//g" /etc/krb5.conf
  sed -i "s/example\.com/$HOST/g" /etc/krb5.conf
  sed -i "s/EXAMPLE\.COM/$REALM/g" /var/kerberos/krb5kdc/kadm5.acl 
  kdb5_util create -s -P dev
  /etc/rc.d/init.d/krb5kdc start
  /etc/rc.d/init.d/kadmin start
  kadmin.local -q "addprinc -pw dev admin/admin"
  kadmin.local -q "addprinc -pw dev ranger/admin"
}

function zeppelin(){
  cd /
  tar -xzv spark.tgz
  mv spark-* spark
  export SPARK_HOME=/spark
  tar -xzvf incubator-zeppelin.tgz
}
