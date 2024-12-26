#!/bin/bash

. conf.sh


# Функция для отображения справки
show_help() {
    echo "Use conf.sh to set params BUS, WIDTH, HEIGHT, COLOR_FORMAT, PIXELFORMAT, BYTES_PER_PIXEL, STREAM_COUNT"
    exit 1
}

# Проверка на наличие аргумента --help
if [[ $1 == "--help" || $1 == "-h" ]]; then
    show_help
fi

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
        media-ctl -v -d $file  -V ''\''ov5647 10-00'$BUS''\'':0 [fmt:'$COLOR_FORMAT'/'$WIDTH'x'$HEIGHT']'
    fi
done
# Захват кадров и сохранение их в файл frame.raw
v4l2-ctl --device /dev/video0 --set-fmt-video=width=${WIDTH},height=${HEIGHT},pixelformat=${PIXELFORMAT}
v4l2-ctl --device /dev/video0 --stream-mmap --stream-to=${output_file} --stream-count=${STREAM_COUNT}

# Вычисление размера кадра
frame_size=$(echo "$WIDTH * $HEIGHT * $BYTES_PER_PIXEL" | bc)

# Разделение файла frame.raw на отдельные кадры
split -b $frame_size  "$output_file" "$binary_dir/output_frame_"

# Конвертация всех кадров в PNG (для YUV422 используем формат VYUY)
i=1
for frame in "$binary_dir"/output_frame_*; do
  mv $frame ${frame}.raw
  ffmpeg -s "${WIDTH}x${HEIGHT}" -pix_fmt uyvy422 -i "${frame}.raw" -frames:v 1 "$png_dir/frame_$i.png" 1> /dev/null 2> /dev/null
  i=$((i+1))
done

# Вывод сообщения о завершении
echo "Файл frame.raw сохранен в директорию: $raw_dir"
echo "Файлы PNG сохранены в директорию: $png_dir"
echo "Временные бинарные файлы сохранены в директорию: $binary_dir"
