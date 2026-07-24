#!/bin/bash
set -e

# HDFS NameNode
if [ ! -d /opt/hadoop/data/namenode/current ]; then
  echo "Formatting NameNode..."
  $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive
fi
 $HADOOP_HOME/sbin/hdfs-daemon.sh start namenode

# Spark Master
 $SPARK_HOME/sbin/start-master.sh

# Ждём, чтобы контейнер не падал
tail -f /opt/spark/logs/*.log