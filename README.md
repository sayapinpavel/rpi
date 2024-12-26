1. Скачайте образ себе на компьютер https://downloads.raspberrypi.com/raspios_full_arm64/images/raspios_full_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-full.img.xz
2. Распакуйте: unxz 2024-07-04-raspios-bookworm-arm64-full.img.xz 
3. Запишите на флешку: dd if=raspios_full_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-full.img of=/dev/sd?
4. Загрузитесь с флешки и настройте сеть для доступа в интернет.
5. Запустите команду sudo rpi-update 
7. Скачайте утилиту rpi-source, запустив на rpi: sudo wget https://raw.githubusercontent.com/RPi-Distro/rpi-source/master/rpi-source -O /usr/local/bin/rpi-source && sudo chmod +x /usr/local/bin/rpi-source && /usr/local/bin/rpi-source -q --tag-update
8. Установите на rpi следующие утилиты: sudo apt install git bc bison flex libssl-dev
9. Запустите на rpi : sudo rpi-source так вы получите исходники ядра в tar.gz архиве. При запуске утилиты rpi-source на первом этапе скачивается ядро, затем оно начинат собираться, вы можете дождаться завершения сборки ядра на rpi, а можете остановить сборку нажав CTRL-C, скопировать исходники ядра себе на хост, распаковать и продолжить сборку ядра у себя на хосте.
10. Для сборки ядра на хосте запустите команду из корня ядра: make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig; затем команду: make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs
11. Скачайте файл https://github.com/sayapinpavel/rpi/blob/main/ov5647.c и поместите его в директорию drivers/media/i2c/
12. Скачайте файл https://github.com/sayapinpavel/rpi/blob/main/ov5647.dtsi и поместите его в директорию arch/arm/boot/dts/overlays
13. Скачайте файл https://github.com/sayapinpavel/rpi/blob/main/ov5647-overlay.dts и поместите его в директорию arch/arm/boot/dts/overlays
14. Запустите повторно make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs; 
15. В директории drivers/media/i2c/ у вас появится модуль ядра ov5647.ko переместите его в директорию /usr/lib/modules/6.6.51-v8+/kernel/drivers/media/i2c/  на rpi
16. В директории arch/arm/boot/dts/overlays/ у вас появится ov5647.dtbo переместите его в директорию /boot/firmware/overlays/ и в /boot/overlays/  на rpi
17. Удалите драйвер на rpi: sudo rm /usr/lib/modules/6.6.51-v8+/kernel/drivers/media/i2c/ov5647.ko.xz
18. Скачайте файл https://github.com/sayapinpavel/rpi/blob/main/config.txt и положите его на rpi в директорию /boot/firmware/  После чего перезагрузите rpi
19. Скачайте скрипт https://github.com/sayapinpavel/rpi/blob/main/get_img.sh и подожите его на rpi в домашнию директорию. Сделайте скрипт исполняемым: chmod +x get_img.sh
20. Скачайте скрипт https://github.com/sayapinpavel/rpi/blob/main/reset_driver.sh и положите его на rpi в домашнию директорию. Сделайте скрипт исполняемым: chmod +x reset_driver.sh
21. Скачайте скрипт https://github.com/sayapinpavel/rpi/blob/main/conf.sh и положите его на rpi туда же где лежат скрипты get_img.sh, reset_driver.sh. Сделайте скрипт исполняемым: chmod +x conf.sh
22. Задайте настройки камеры в conf.sh
23. После каждого изменения параметров в conf.sh нужнон перезагружать драйвер при помощи запуска скрипта ./reset_driver.sh
24. Чтобы получить картинку запустите скрипт: ./get_img.sh
25. Запуск скриптов для приема/передачи видео потока:
    1. На обеих системах (rpi и клиентском компьютере) установите GStreamer:
    ```
    sudo apt update;
    sudo apt install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly
    ```
    3. Скопируйте файл start_stream.sh на ваш Raspberry Pi
    4. Запустите скрипт с указанием ширины, высоты, IP-адреса клиентского компьютера  и порта, пример:
    ```
 	./start_stream.sh 1920 1080 192.168.88.249 5000
    ```
    5. Скрипт начнет передавать видеопоток через UDP на указанный IP-адрес и порт
    6. Скопируйте файл receive_stream.sh на клиентский компьютер (Linux). Запустите скрипт с указанием порта, например:
	```
 	./receive_stream.sh 5000
 	```
    7. Скрипт начнет прием видеопотока через указанный UDP-порт и выведет его на экран.
    8. Для приема видео потока вы можете проспустить шаг 6 и запустить ffplay -i rtp://127.0.0.1:5000