#!/bin/bash

# Функция для отображения справки
show_help() {
    echo "Usage: $0 <width> <height> <bytes_per_pixel> <stream_count>"
    echo ""
    echo "Parameters:"
    echo "  width             Width of the frame in pixels (e.g., 1920)."
    echo "  height            Height of the frame in pixels (e.g., 1080)."
    echo "  bytes_per_pixel   Number of bytes per pixel (e.g., 2 for YUV422)."
    echo "  stream_count      Number of frames to capture (e.g., 10)."
    echo ""
    echo "Example:"
    echo "  $0 1920 1080 2 10"
    exit 1
}

# Проверка на наличие аргумента --help
if [[ $1 == "--help" || $1 == "-h" ]]; then
    show_help
fi

# Проверка на количество аргументов
if [ "$#" -ne 4 ]; then
    echo "Error: Incorrect number of arguments."
    show_help
fi

# Получаем параметры: ширина, высота, количество байт на пиксель и количество кадров
width=$1
height=$2
bytes_per_pixel=$3  # Например, 2 для YUV422 (VYUY)
stream_count=$4     # Количество кадров для захвата

# Создание уникальной директории в домашнем каталоге на основе текущего времени
output_dir="$HOME/capture_$(date +%Y%m%d_%H%M%S)"
raw_dir="$output_dir/raw"        # Директория для сохранения frame.raw
binary_dir="$output_dir/binary"  # Поддиректория для временных бинарных файлов
png_dir="$output_dir/png"        # Поддиректория для файлов PNG

mkdir -p "$raw_dir" "$binary_dir" "$png_dir"  # Создаем все три директории

# Имя для сохранения бинарного файла
output_file="$raw_dir/frame.raw"

# Настройка устройства через media-ctl и v4l2-ctl с параметрами ширины и высоты
ls /dev/media? | while read file; do 
    media-ctl -v -d $file -p | grep ov5647 1> /dev/null
    if [ "$?" -eq "0" ]; then 
        media-ctl -v -d $file -V ''\''ov5647 10-0036'\'':0 [fmt:Y8_1X8/1920x1080]'
    fi
done

# Захват кадров и сохранение их в файл frame.raw
v4l2-ctl --device /dev/video0 --set-fmt-video=width=${width},height=${height},pixelformat=GREY
v4l2-ctl --device /dev/video0 --stream-mmap --stream-to=${output_file} --stream-count=${stream_count}

# Вычисление размера кадра
frame_size=$(echo "$width * $height * $bytes_per_pixel" | bc)

# Разделение файла frame.raw на отдельные кадры
split -b $frame_size  "$output_file" "$binary_dir/output_frame_"

# Конвертация всех кадров в PNG (для YUV422 используем формат VYUY)
i=1
for frame in "$binary_dir"/output_frame_*; do
  mv $frame ${frame}.raw
  ffmpeg -s "${width}x${height}" -pix_fmt uyvy422 -i "${frame}.raw" -frames:v 1 "$png_dir/frame_$i.png" 1> /dev/null 2> /dev/null
  i=$((i+1))
done

# Вывод сообщения о завершении
echo "Файл frame.raw сохранен в директорию: $raw_dir"
echo "Файлы PNG сохранены в директорию: $png_dir"
echo "Временные бинарные файлы сохранены в директорию: $binary_dir"
