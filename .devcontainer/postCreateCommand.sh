#!/bin/bash
set -e

cd .devcontainer

# Сборка образа один раз
docker compose build

# Запуск кластера
docker compose up -d

# Ждём регистрацию workers
echo "Ожидание регистрации workers..."
for i in {1..30}; do
  WORKERS=$(curl -s http://localhost:8080/json 2>/dev/null | grep -o '"aliveWorkers":[0-9]*' | grep -o '[0-9]*' || echo 0)
  if [ "$WORKERS" = "2" ]; then
    echo "✓ 2 workers зарегистрированы"
    break
  fi
  sleep 5
done

# Создание HDFS-директорий
docker exec spark-master bash -c '
  $HADOOP_HOME/bin/hdfs dfs -mkdir -p /tmp /user/vscode
  $HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /tmp
'

echo "Кластер готов: Spark Master UI на http://localhost:8080, HDFS UI на http://localhost:9870"