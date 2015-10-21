FROM sequenceiq/dnsmasq:pam-fix

# Setup Ambari
ADD repos/* /etc/yum.repos.d/
RUN yum install -y ambari-* sudo tar unzip wget curl postgresql-jdbc net-snmp net-snmp-utils openssl-devel
RUN ambari-server setup --silent
RUN ambari-server setup --jdbc-db=postgres --jdbc-driver=/usr/share/java/postgresql-jdbc.jar

# Kerberos support
RUN yum install -y krb5-server krb5-libs krb5-auth-dialog krb5-workstation
# HST tool
#RUN rpm -ivh /etc/yum.repos.d/hst.rpm

# pre-install HDP packages then remove the repo so they wont conflict with Ambari installed HDP repos
RUN yum install -y hadoop* zookeeper hive_* hbase_* phoenix_* ranger* rpcbind storm_* kafka_* pig_* spark_* falcon_* oozie_* lzo snappy snappy-devel
RUN rm /etc/yum.repos.d/hdp*.repo

# Setup networking
ADD scripts /scripts
RUN cp /scripts/public-hostname.sh /etc/ambari-agent/conf/public-hostname.sh
RUN cp /scripts/internal-hostname.sh /etc/ambari-agent/conf/internal-hostname.sh
RUN sed -i "/\[agent\]/ a public_hostname_script=\/etc\/ambari-agent\/conf\/public-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini
RUN sed -i "/\[agent\]/ a hostname_script=\/etc\/ambari-agent\/conf\/internal-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini
RUN sed -i "s/agent.task.timeout=900/agent.task.timeout=2000/" /etc/ambari-server/conf/ambari.properties

# Starts ambari agent, server, sets up Postgres dbs
RUN /scripts/initialize.sh

# End user setup -- customize as desired
# Ambari
EXPOSE 8080
# Zeppelin
EXPOSE 8081
# Ranger
EXPOSE 6080
# Spark
EXPOSE 4040
# Jupyter/Zeppelin
EXPOSE 9990-9999
# Kafka
EXPOSE 6667
# ZooKeeper
EXPOSE 2181 2888 3888
# HBase
EXPOSE 16000 16010 16020 16030 9090 9095
# HDFS
EXPOSE 50070 50470 8020 9000 50075 50475 50010 50020 50090
# Hue
EXPOSE 8888
# MR
EXPOSE 10020 19888 13562
# YARN
EXPOSE 8141 45454 10200 8188 8190 19888 8088
# Hive
EXPOSE 10000 9999 9933
# Tez
EXPOSE 12999 10030
# Storm
EXPOSE 3772 3773 6627 6700-6704 8744
# Solr
EXPOSE 8983
# Kylin
EXPOSE 7070
# Kerberos
EXPOSE 88
# Expose SSH if desired
EXPOSE 22

RUN /scripts/dev-setup.sh

VOLUME /grid/0
CMD ["/scripts/start-server.sh"]
