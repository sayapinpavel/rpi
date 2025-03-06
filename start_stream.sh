#!/bin/bash

. conf.sh

# Функция для отображения справки
show_help() {
    echo "Использование: $0 <ширина> <высота> <IP-адрес> <порт>"
    echo ""
    echo "Параметры:"
    echo "  ширина     Ширина видео в пикселях (например, 1920)"
    echo "  высота     Высота видео в пикселях (например, 1080)"
    echo "  IP-адрес   IP-адрес получателя (например, 192.168.88.249)"
    echo "  порт       Порт UDP для отправки потока (например, 5000)"
    echo ""
    echo "Пример:"
    echo "  $0 1920 1080 192.168.88.249 5000"
    exit 0
}

# Проверка на наличие флага --help или недостатка аргументов
if [[ "$1" == "--help" ]]; then
    show_help
elif [ "$#" -ne 2 ]; then
    echo "Ошибка: недостаточно аргументов."
    echo "Введите '$0 --help' для получения справки."
    exit 1
fi

# Присвоение аргументов переменным
IP_ADDRESS=$1
PORT=$2


if [[ "$GST_FORMAT" == "GRAY8" ]]; then
    gst-launch-1.0 v4l2src device=/dev/video0 ! queue ! video/x-raw,width=${WIDTH},height=${HEIGHT},format=${GST_FORMAT},framerate=30/1 ! videoconvert ! video/x-raw,format=I420 ! queue ! jpegenc ! queue ! rtpjpegpay ! queue ! udpsink host=${IP_ADDRESS} port=${PORT}
else
    gst-launch-1.0 v4l2src device=/dev/video0 ! queue ! video/x-raw,width=${WIDTH},height=${HEIGHT},format=UYVY,framerate=30/1 ! videoconvert ! queue ! jpegenc ! queue ! rtpjpegpay ! queue ! udpsink host=${IP_ADDRESS} port=${PORT}
fi

#gst-launch-1.0 v4l2src device=/dev/video0 ! queue ! video/x-raw,width=${WIDTH},height=${HEIGHT},format=GRAY8,framerate=30/1 ! videoconvert ! queue ! jpegenc ! queue ! rtpjpegpay ! queue ! udpsink host=${IP_ADDRESS} port=${PORT}
#gst-launch-1.0 v4l2src device=/dev/video0 ! queue ! video/x-raw,width=${WIDTH},height=${HEIGHT},format=${GST_FORMAT},framerate=30/1 ! videoconvert ! video/x-raw,format=I420 ! queue ! jpegenc ! queue ! rtpjpegpay ! queue ! udpsink host=${IP_ADDRESS} port=${PORT}
