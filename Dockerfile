FROM sequenceiq/dnsmasq:pam-fix

# Setup Ambari
ADD repos/* /etc/yum.repos.d/
RUN yum install -y ambari-* wget git sudo tar git curl postgresql-jdbc vim
RUN ambari-server setup --silent
RUN ambari-server setup --jdbc-db=postgres --jdbc-driver=/usr/share/java/postgresql-jdbc.jar

# Kerberos support
RUN yum install -y krb5-server krb5-libs krb5-auth-dialog krb5-workstation
# HST tool
RUN rpm -ivh /etc/yum.repos.d/hst.rpm

# pre-install yum packages
RUN yum install -y hadoop* lzo net-snmp net-snmp-utils snappy snappy-devel unzip zookeeper hbase_* phoenix_* ranger_* rpcbind storm_* kafka_* pig_* spark_* apache-maven

ENV JAVA_HOME /usr/jdk64/jdk1.8.0_40
ENV PATH $JAVA_HOME/bin:$PATH

# Setup Python packages
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
#RUN pip install numpy scipy

# Setup networking
ADD scripts /scripts
RUN cp /scripts/public-hostname.sh /etc/ambari-agent/conf/public-hostname.sh
RUN cp /scripts/internal-hostname.sh /etc/ambari-agent/conf/internal-hostname.sh
RUN sed -i "/\[agent\]/ a public_hostname_script=\/etc\/ambari-agent\/conf\/public-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini
RUN sed -i "/\[agent\]/ a hostname_script=\/etc\/ambari-agent\/conf\/internal-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini
RUN sed -i "s/agent.task.timeout=900/agent.task.timeout=2000/" /etc/ambari-server/conf/ambari.properties

RUN /scripts/install-cluster.sh
RUN cp /scripts/control.sh /root/.bashrc
RUN cp /scripts/vimrc /root/.vimrc

# Ambari and various UIs
EXPOSE 8000-8100
EXPOSE 6080 19888 4040
# Jupyter/Zeppelin
EXPOSE 9990-9999
# ZooKeeper, HBase, Kafka, Hive
EXPOSE 6667 2181 10000

VOLUME /grid/0

CMD ["/scripts/start-server.sh"]
