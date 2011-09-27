#!/bin/sh
gource --user-image-dir .git/avatar/ --highlight-all-users --user-scale 3.0 --font-size 24 \
--title 'Rails Portal: http://github.com/concord-consortium/rigse' --git-branch rails3.0 \
--file-filter 'vendor|public\/javascripts\/.+\/.+' --file-idle-time 10 --key --highlight-dirs \
--camera-mode track --bloom-intensity 0.3 --seconds-per-day 5 --auto-skip-seconds 1.0 \
--background 000000 --multi-sampling -1280x720
