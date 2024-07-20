#!/bin/sh

while [ 1 ]; do
  h264files=$(ls /mnt/video_encode/*.str)

  mkdir -p /mnt/anyka_hack/web_interface/www/video

  for i in $h264files; do
    filename="${i//.str/}"
    filename="${filename##*/}"
    echo $filename
    if [[ ! -f /mnt/anyka_hack/web_interface/www/video/$filename.mp4 ]]; then
      mv /mnt/video_encode/$filename.str /mnt/video_encode/$filename.h264
      /mnt/anyka_hack/ffmpeg/ffmpeg -threads 1 -i "/mnt/video_encode/$filename.h264" -c:v copy -f mp4 "/mnt/anyka_hack/web_interface/www/video/$filename.mp4"
    fi
  done
  sleep 300
done
