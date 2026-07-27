#!/bin/bash
set -e

# Убедимся, что директория для логов существует
mkdir -p /opt/spark/logs/events

# HDFS NameNode
if [ ! -d /opt/hadoop/data/namenode/current ]; then
  echo "Formatting NameNode..."
  $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive
fi
 $HADOOP_HOME/bin/hdfs --daemon start namenode

# Spark Master
 $SPARK_HOME/sbin/start-master.sh

# Держим контейнер запущенным (заменяем tail на sleep)
echo "Spark Master запущен, удерживаем контейнер..."
sleep infinity