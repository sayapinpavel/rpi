#!/bin/bash

# Функция для отображения справки
show_help() {
    echo "Использование: $0 <порт>"
    echo ""
    echo "Параметры:"
    echo "  порт   Порт UDP для приема потока (например, 5000)"
    echo ""
    echo "Пример:"
    echo "  $0 5000"
    exit 0
}

# Проверка на наличие флага --help или недостатка аргументов
if [[ "$1" == "--help" ]]; then
    show_help
elif [ "$#" -ne 1 ]; then
    echo "Ошибка: недостаточно аргументов."
    echo "Введите '$0 --help' для получения справки."
    exit 1
fi

# Присвоение аргумента переменной
PORT=$1

# Запуск GStreamer для приема потока
gst-launch-1.0 udpsrc port=${PORT} ! queue silent=false ! h264parse ! queue silent=false ! avdec_h264 ! videoconvert ! fpsdisplaysink video-sink=autovideosink text-overlay=true sync=false