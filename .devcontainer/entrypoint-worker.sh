#!/bin/bash
set -e

mkdir -p /opt/spark/logs

# Ждём NameNode (используем встроенные возможности bash вместо nc)
echo "Ожидание NameNode на spark-master:9000..."
until bash -c '</dev/tcp/spark-master/9000' 2>/dev/null; do
    sleep 2
done
echo "NameNode доступен!"

# HDFS DataNode
 $HADOOP_HOME/bin/hdfs --daemon start datanode

# Spark Worker
 $SPARK_HOME/sbin/start-worker.sh spark://spark-master:7077

# Держим контейнер запущенным
echo "Spark Worker запущен, удерживаем контейнер..."
sleep infinity