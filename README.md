1. скачайте образ себе на компьютер https://downloads.raspberrypi.com/raspios_full_arm64/images/raspios_full_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-full.img.xz
2. распакуйте: unxz 2024-07-04-raspios-bookworm-arm64-full.img.xz 
3. запишите на флешку: dd if=raspios_full_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-full.img of=/dev/sd?
4. Загрузитесь с флешки и настройте сеть для доступа в интернет.
5. Запустите команду sudo rpi-update 
7. Скачайте утилиту rpi-source, запустив на rpi: sudo wget https://raw.githubusercontent.com/RPi-Distro/rpi-source/master/rpi-source -O /usr/local/bin/rpi-source && sudo chmod +x /usr/local/bin/rpi-source && /usr/local/bin/rpi-source -q --tag-update
8. Запустите на rpi : sudo rpi-source так вы получите исходники ядра в tar.gz архиве. Скопируйте исходники ядра себе на хост и распакуйте.
9. Запустите на хосте: make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig 
10. Запустите на хосте: make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs
11. Скачайте файл https://github.com/sayapinpavel/rpi/blob/main/ov5647.c и поместите его в директорию drivers/media/i2c/
12. Запустите повторно make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs
13. Скачайте файл https://github.com/sayapinpavel/rpi/blob/main/config.txt и положите его на rpi в директорию /boot/firmware/  После чего перезагрузите rpi
14. Получить картинку: media-ctl  -v -d /dev/media2 -V ''\''ov5647 10-0036'\'':0 [fmt:Y8_1X8/640x480]'; v4l2-ctl --device /dev/video0 --set-fmt-video=width=640,height=480,pixelformat=GREY; v4l2-ctl --device /dev/video0 --stream-mmap --stream-to=frame.raw --stream-count=1
