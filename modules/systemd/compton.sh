#!/bin/sh
set -eu

#Radeon block bug
#WORKAROUND

vendor_id=0
if [ -f /sys/class/drm/card0/device/vendor ]; then
  read -r vendor_id < /sys/class/drm/card0/device/vendor
fi

if [ -f /proc/sys/kernel/yield_type ]; then
  set -- nj schedtool -I -e compton
else
  set -- nj compton
fi

#export vblank_mode=3
# check amd
if [ "$vendor_id" = "0x1002" ]; then
  #EARLY to give enough time to start
  "$@" &
  # xorg 1.19 bug? has to be ready before wp is set
  #sleep 1
else
  exec "$@" -b
fi
