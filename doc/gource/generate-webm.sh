#!/bin/sh
gource --user-image-dir .git/avatar/ --highlight-all-users --user-scale 3.0 --font-size 24 \
--file-filter 'vendor|public\/javascripts\/.+\/.+' --file-idle-time 4 --key --highlight-dirs \
--camera-mode track --bloom-intensity 0.2 --max-files 300 \
--title 'Rails Portal: http://github.com/concord-consortium/rigse' --git-branch rails3.0 \
--disable-progress  --seconds-per-day 0.2 --auto-skip-seconds 1.0 --background 000000 \
--multi-sampling -1280x720 --stop-at-end --output-framerate 60 --output-ppm-stream - | \
ffmpeg -y -r 60 -b 10000k -f image2pipe -vcodec ppm -vf "format=yuv420p" -i - \
-vcodec libvpx -b 3000k gource/rails-portal.webm