#!/bin/bash
set -e

# Список контейнеров кластера
CONTAINERS=("spark-master" "spark-worker-1" "spark-worker-2")

# Список библиотек для установки (добавляйте или удаляйте по необходимости)
PACKAGES=(
    # "jupyterlab"
    # "numpy"
    # "pandas"
    # "scipy"
    # "matplotlib"
    # "seaborn"
    # "some-private-package==1.2.3"
    "fsspec"
)

echo "Начинаем установку библиотек на узлы кластера..."
echo "Список пакетов: ${PACKAGES[*]}"
echo "================================================="

for container in "${CONTAINERS[@]}"; do
    echo "➡️ Обработка контейнера: $container"
    
    # Проверяем, запущен ли контейнер
    if ! docker ps --format '{{.Names}}' | grep -q "^$container$"; then
        echo "⚠️ Внимание: Контейнер $container не запущен. Пропуск..."
        echo "-------------------------------------------------"
        continue
    fi

    echo "⏳ Установка пакетов в $container..."
    # Используем --quiet для less spam, но при ошибке pip выведет причину
    if docker exec "$container" pip3 install --quiet "${PACKAGES[@]}"; then
        echo "✅ Успешно установлено в $container."
    else
        echo "❌ Ошибка при установке в $container. Проверьте логи."
    fi
    echo "-------------------------------------------------"
done

echo "🎉 Установка библиотек завершена!"