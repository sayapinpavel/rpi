#!/bin/sh

ls /dev/media? | while read file; do media-ctl  -v -d $file -p | grep ov5647 1> /dev/null; if [ "$?" -eq "0" ]; then media-ctl  -v -d $file -V ''\''ov5647 10-0036'\'':0 [fmt:Y8_1X8/640x480]'; fi; done
v4l2-ctl --device /dev/video0 --set-fmt-video=width=640,height=480,pixelformat=GREY;
v4l2-ctl --device /dev/video0 --stream-mmap --stream-to=frame.raw --stream-count=1;

