#!/bin/sh
set -eu
#exec 2>&1
trap 'err=$?; if [ $err -gt 0 ]; then echo error $err; fi' 0

admin_user=$1
shift

content=$(grep '^Subject\|^From')
subject=$(printf '%s\n' "$content" | grep '^Subject:' | sed 's/^Subject: //' | head -1)
from=$(printf '%s\n' "$content" | grep '^From:' | sed 's/^From: //' | head -1)

hostname=$(hostname)
if printf '%s\n' "$from" | grep -q "^.*<$admin_user@$hostname\\.localdomain>$"; then
  if printf '%s\n' "$subject" | grep -q '^Critical event: '; then
    summary=$(printf '%s\n' "$subject" | sed 's/^Critical event: //')
    body='See journal for details'
    set -- -u critical -t 10000
  else
    set -- -u critical
    summary=${subject:-'Root got mail'}
  fi
else
  summary=${subject:-'New mail'}
fi


uid=$(id -u)
if [ -n "${body:-}" ]; then
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send -a "System watch" "$@" -- "$summary" "$body" || true
else
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send -a "System watch" "$@" -- "$summary" || true
fi
