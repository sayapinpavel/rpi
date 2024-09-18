#!/bin/sh

media-ctl  -v -d /dev/media2 -V ''\''ov5647 10-0036'\'':0 [fmt:Y8_1X8/640x480]';
v4l2-ctl --device /dev/video0 --set-fmt-video=width=640,height=480,pixelformat=GREY;
v4l2-ctl --device /dev/video0 --stream-mmap --stream-to=frame.raw --stream-count=1;