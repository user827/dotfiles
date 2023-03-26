#!/bin/sh
set -eu

# only opengl-hq + display resample rpevents tearing
vid=$HOME/Videos/vidwallpaper
socket=$XDG_RUNTIME_DIR/mpv/mywallmovie.$DISPLAY
[ -d $XDG_RUNTIME_DIR/mpv ] || mkdir $XDG_RUNTIME_DIR/mpv
if [ -x "$vid" ]; then
  exec bash "$vid" "$socket"
fi
# only opengl-hq + display resample rpevents tearing
# set -- mpv --vo=opengl --heartbeat-cmd="" --really-quiet --cursor-autohide=no \
  # cwinwrap is required even if not painting to overlay
set -- xwinwrap -ov -fs -- mpv --vo=opengl --really-quiet  --cursor-autohide=no \
  --no-config --profile=opengl-hq --video-sync=display-resample \
  --no-stop-screensaver --no-audio --no-input-terminal --no-osc --input-ipc-server="$socket" \
  --input-conf=/dev/null --no-input-default-bindings --loop=inf --wid WID
while read -r arg; do
  set -- "$@" "$arg"
done < "$vid"
#if [ -f "$vid".vgf ]; then
  # set -- "$@" --script="$HOME/.config/mpv/vgf.lua" --speed=0.50
  #[ -f "$vid".pausefile ] && set -- "$@" --script-opts=vgf-pausefile="$vid".pausefile
  #[ -f "$vid".chapters ] && set -- "$@" --chapters-file="$vid".chapters
#fi
exec "$@"
