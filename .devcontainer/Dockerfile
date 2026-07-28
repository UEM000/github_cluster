FROM ubuntu:22.04

ARG SPARK_VERSION=3.5.1
ARG HADOOP_VERSION=3.3.4

# НОВОЕ: добавлены HADOOP_CONF_DIR, YARN_CONF_DIR и LD_LIBRARY_PATH
ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    SPARK_HOME=/opt/spark \
    HADOOP_HOME=/opt/hadoop \
    PYSPARK_PYTHON=/usr/bin/python3 \
    HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop \
    YARN_CONF_DIR=/opt/hadoop/etc/hadoop \
    LD_LIBRARY_PATH=$JAVA_HOME/lib/server:$HADOOP_HOME/lib/native:$LD_LIBRARY_PATH \
    ARROW_LIBHDFS_DIR=$HADOOP_HOME/lib/native

RUN apt-get update && apt-get install -y --no-install-recommends \
      openjdk-17-jdk-headless \
      python3.10 python3.10-venv python3.10-dev python3-pip \
      openssh-server openssh-client \
      curl wget vim procps net-tools iproute2 \
      && ln -sf /usr/bin/python3.10 /usr/bin/python3 \
      && rm -rf /var/lib/apt/lists/*

# Spark
RUN wget -q https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz -O /tmp/spark.tgz \
    && tar -xzf /tmp/spark.tgz -C /opt/ \
    && ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop3 /opt/spark \
    && rm /tmp/spark.tgz

# Hadoop
RUN wget -q https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -O /tmp/hadoop.tgz \
    && tar -xzf /tmp/hadoop.tgz -C /opt/ \
    && ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop \
    && rm /tmp/hadoop.tgz

ENV PATH=$PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# НОВОЕ: явно устанавливаем pyarrow и fsspec рядом с pyspark
RUN pip3 install --no-cache-dir pyspark==3.5.1 py4j==0.10.9.7 pyarrow fsspec

# SSH
RUN ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa \
    && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
    && chmod 600 /root/.ssh/authorized_keys

# Точечное копирование конфигов
COPY spark/spark-env.sh /opt/spark/conf/spark-env.sh
COPY spark/spark-defaults.conf /opt/spark/conf/spark-defaults.conf
COPY spark/hdfs/core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
COPY spark/hdfs/hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml

COPY entrypoint-master.sh /entrypoint-master.sh
COPY entrypoint-worker.sh /entrypoint-worker.sh
RUN chmod +x /entrypoint-master.sh /entrypoint-worker.sh

EXPOSE 7077 8080 8081 4040 9000 9870 9864 8888