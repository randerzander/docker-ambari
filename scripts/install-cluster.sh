#!/bin/bash

# fixing pgsql issue, setting Hive Metastore, Ranger permissions
rm -rf /tmp/.s.PGSQL.5432.*
echo 'local hive hive md5' >> /var/lib/pgsql/data/pg_hba.conf
echo 'host hive hive 0.0.0.0/0 md5' >> /var/lib/pgsql/data/pg_hba.conf
echo 'local all postgres,ranger,rangeradmin,rangerlogger md5' >> /var/lib/pgsql/data/pg_hba.conf
echo 'host all postgres,ranger,rangeradmin,rangerlogger 0.0.0.0/0 md5' >> /var/lib/pgsql/data/pg_hba.conf
echo 'host all postgres,ranger,rangeradmin,rangerlogger ::/0 md5' >> /var/lib/pgsql/data/pg_hba.conf

while [ -z "$(netstat -tulpn | grep 8080)" ]; do
  ambari-server start
  ambari-agent start
  sleep 30
done

# Ambari & Postgres started- create dbs and accounts for Ranger
runuser -l postgres -c "psql -c 'create user hive;'"
runuser -l postgres -c "psql -c \"alter user hive with PASSWORD 'dev';\""
runuser -l postgres -c "psql -c 'create database hive;'"
runuser -l postgres -c "psql -c 'alter database hive owner to hive;'"
runuser -l postgres -c "psql -c 'create user ranger;'"
runuser -l postgres -c "psql -c \"alter user ranger with PASSWORD 'dev';\""
runuser -l postgres -c "psql -c 'create user rangeradmin;'"
runuser -l postgres -c "psql -c \"alter user rangeradmin with PASSWORD 'dev';\""
runuser -l postgres -c "psql -c 'create user rangerlogger;'"
runuser -l postgres -c "psql -c \"alter user rangerlogger with PASSWORD 'dev';\""
runuser -l postgres -c "psql -c 'create database ranger;'"
runuser -l postgres -c "psql -c 'alter database ranger owner to rangeradmin;'"
runuser -l postgres -c "psql -c 'create database ranger_audit;'"
runuser -l postgres -c "psql -c 'alter database ranger_audit owner to rangerlogger;'"

#curl --user admin:admin -H 'X-Requested-By: ambari' -X POST http://amb0.dev:8080/api/v1/blueprints/dev -d @/blueprint.json
#curl --user admin:admin -H 'X-Requested-By: ambari' -X POST http://amb0.dev:8080/api/v1/clusters/dev -d @/host_mapping.json
