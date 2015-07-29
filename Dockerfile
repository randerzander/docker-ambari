FROM sequenceiq/dnsmasq:pam-fix

# Setup Ambari
ADD repos/* /etc/yum.repos.d/
RUN yum install -y ambari-* sudo tar unzip wget curl postgresql-jdbc net-snmp net-snmp-utils
RUN ambari-server setup --silent
RUN ambari-server setup --jdbc-db=postgres --jdbc-driver=/usr/share/java/postgresql-jdbc.jar

# Kerberos support
RUN yum install -y krb5-server krb5-libs krb5-auth-dialog krb5-workstation
# HST tool
#RUN rpm -ivh /etc/yum.repos.d/hst.rpm

# pre-install HDP packages
RUN yum install -y hadoop* zookeeper hbase_* phoenix_* ranger_* rpcbind storm_* kafka_* pig_* spark_* lzo snappy snappy-devel

# Setup networking
ADD scripts /scripts
RUN cp /scripts/public-hostname.sh /etc/ambari-agent/conf/public-hostname.sh
RUN cp /scripts/internal-hostname.sh /etc/ambari-agent/conf/internal-hostname.sh
RUN sed -i "/\[agent\]/ a public_hostname_script=\/etc\/ambari-agent\/conf\/public-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini
RUN sed -i "/\[agent\]/ a hostname_script=\/etc\/ambari-agent\/conf\/internal-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini
RUN sed -i "s/agent.task.timeout=900/agent.task.timeout=2000/" /etc/ambari-server/conf/ambari.properties

# Ambari and various UIs
EXPOSE 8000-8100
EXPOSE 6080 19888 4040
# Jupyter/Zeppelin
EXPOSE 9990-9999
# ZooKeeper, HBase, Kafka, Hive, Kylin
EXPOSE 6667 2181 10000 7070

# Starts ambari agent, server, sets up Postgres dbs
RUN /scripts/initialize.sh

# End user setup -- customize as desired
RUN yum install -y git vim apache-maven
# Setup Python packages
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
#RUN pip install numpy scipy
RUN cp /scripts/bashrc /root/.bashrc
RUN cp /scripts/vimrc /root/.vimrc

VOLUME /grid/0
CMD ["/scripts/start-server.sh"]
