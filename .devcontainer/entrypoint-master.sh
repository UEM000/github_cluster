#!/bin/bash
set -e

# HDFS NameNode
if [ ! -d /opt/hadoop/data/namenode/current ]; then
  echo "Formatting NameNode..."
  $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive
fi
 $HADOOP_HOME/bin/hdfs --daemon start namenode

# Создаём директорию для логов Spark, иначе History Server упадёт
mkdir -p /opt/spark/logs/events

# Spark Master
 $SPARK_HOME/sbin/start-master.sh

# Ждём, чтобы контейнер не падал
tail -f /opt/spark/logs/*.log