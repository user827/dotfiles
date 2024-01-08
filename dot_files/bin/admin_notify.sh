#!/bin/sh
set -eux
exec 2>&1

trap 'err=$?; if [ $err -gt 0 ]; then echo error $err; fi' 0

content=$(grep '^Subject\|^From')
subject=$(printf '%s\n' "$content" | grep '^Subject:' | sed 's/^Subject: //' | head -1)
from=$(printf '%s\n' "$content" | grep '^From:' | sed 's/^From: //' | head -1)

hostname=$(hostname)
if printf '%s\n' "$from" | grep -q "^.*Mail Delivery System <MAILER-DAEMON@$hostname\\.localdomain>$"; then
  :
elif printf '%s\n' "$from" | grep -q "^.*root <root@$hostname\\.localdomain>$" && printf '%s\n' "$subject" | grep -q '^sec: '; then
  summary=$(printf '%s\n' "$subject" | sed 's/^sec: //')
  echo "Subject: Critical event: $summary" | sendmail "$@"
else
  echo "Subject: root got mail" | sendmail "$@"
fi
