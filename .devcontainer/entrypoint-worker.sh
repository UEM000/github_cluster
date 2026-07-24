#!/bin/bash
set -e

# Ждём NameNode
until nc -z spark-master 9000; do sleep 2; done

# HDFS DataNode
 $HADOOP_HOME/sbin/hdfs-daemon.sh start datanode

# Spark Worker
 $SPARK_HOME/sbin/start-worker.sh spark://spark-master:7077

tail -f /opt/spark/logs/*.log