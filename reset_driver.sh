#!/bin/bash

. conf.sh

ret=0

if [[ $COLOR_FORMAT == "VYUY8_2X8" ]] && [[ $WIDTH -eq 1920 ]] && [[ $HEIGHT -eq 1080 ]]
then
  ret=0
elif [[ $COLOR_FORMAT == "Y8_1X8" ]] && [[ $WIDTH -eq 1920 ]] && [[ $HEIGHT -eq 1080 ]]
then
  ret=1
elif [[ $COLOR_FORMAT == "VYUY8_2X8" ]] && [[ $WIDTH -eq 640 ]] && [[ $HEIGHT -eq 480 ]]
then
  ret=2
fi

sudo dtoverlay -r  ov5647
sudo dtoverlay ov5647,address=0x$BUS,resolution=$ret