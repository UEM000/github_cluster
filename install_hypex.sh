#!/bin/bash
set -e

WHEEL_NAME="hypex-1.0.3-py3-none-any.whl"
WHEEL_PATH=$(find /workspaces -name "$WHEEL_NAME" | head -n 1)

if [ -z "$WHEEL_PATH" ]; then
    echo "❌ Ошибка: Файл $WHEEL_NAME не найден в проекте."
    exit 1
fi

echo "✅ Найден wheel: $WHEEL_PATH"
echo "Начинаем установку на все ноды кластера..."

# Список контейнеров кластера
CONTAINERS=("spark-master" "spark-worker-1" "spark-worker-2")

for container in "${CONTAINERS[@]}"; do
    echo "========================================="
    echo "⏳ Настройка $container..."
    
    # 1. Копируем wheel с хоста (Codespace) в контейнер
    docker cp "$WHEEL_PATH" "$container:/tmp/$WHEEL_NAME"
    
    # 2. Устанавливаем пакет внутри контейнера
    docker exec "$container" pip3 install --force-reinstall "/tmp/$WHEEL_NAME"
    
    # 3. Проверяем, что библиотека импортируется
    echo -n "🔍 Проверка импорта в $container: "
    docker exec "$container" python3 -c "import hypex; print('OK')" || echo "❌ Ошибка импорта"
done

echo "========================================="
echo "🎉 Готово! Библиотека hypex установлена на все ноды."
