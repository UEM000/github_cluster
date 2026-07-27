#!/bin/bash
set -e

CONTAINER_NAME="spark-master"
PORT=8888

echo "1. Проверка контейнера $CONTAINER_NAME..."
if ! docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    echo "❌ Ошибка: Контейнер $CONTAINER_NAME не запущен."
    echo "   Сначала запустите кластер: cd .devcontainer && docker compose up -d"
    exit 1
fi

echo "2. Установка JupyterLab в контейнер (это займет несколько секунд при первом запуске)..."
docker exec $CONTAINER_NAME pip3 install -q jupyterlab

echo "3. Запуск Jupyter сервера..."
# Проверяем, не запущен ли уже сервер
if docker exec $CONTAINER_NAME bash -c "pgrep -f 'jupyter-lab'" > /dev/null 2>&1; then
    echo "   Jupyter уже был запущен."
else
    # Запускаем в фоновом режиме (-d)
    docker exec -d -w /opt/spark $CONTAINER_NAME bash -c "jupyter lab --ip=0.0.0.0 --port=$PORT --no-browser --allow-root > /opt/spark/jupyter.log 2>&1"
    echo "   Ожидание запуска сервера..."
    sleep 5
fi

echo "4. Получение токена доступа..."
# Извлекаем токен из списка запущенных серверов Jupyter
TOKEN=$(docker exec $CONTAINER_NAME jupyter server list 2>/dev/null | grep -o 'token=[a-z0-9]*' | head -n 1 | cut -d'=' -f2)

if [ -z "$TOKEN" ]; then
    echo "❌ Не удалось получить токен. Проверьте логи:"
    docker exec $CONTAINER_NAME cat /opt/spark/jupyter.log
    exit 1
fi

echo "================================================="
echo "✅ Jupyter успешно запущен!"
echo "================================================="
echo ""
echo "1. Откройте вкладку 'Ports' (Порты) внизу VS Code."
echo "2. Найдите порт $PORT и нажмите на ссылку (URL вида https://<имя-codespace>-$PORT.app.github.dev)."
echo "3. На странице Jupyter вставьте следующий токен:"
echo ""
echo "   🔑 Токен: $TOKEN"
echo ""
echo "================================================="