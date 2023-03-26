#!/bin/sh
set -eu

instance=$1

result=$(systemctl --user show -p Result "myautolock@$instance")

warn() {
  printf '<3>%s\n' "$*" >&2
}

if [ "$result" = "Result=start-limit" ]; then
  warn "Start-limit reached - terminating the session"
  # This kills this script too even thought this is not in a session.
  #   -> is in conflict with startx-stop
  loginctl terminate-session "${XDG_SESSION_ID:-}" && { sleep 5 || true; }
  warn "Still alive - terminating the user"
  loginctl terminate-user "$(id -un)" && { sleep 5 || true; }

  warn "Still alive - terminating everything"
  trap true TERM || true
  #TODO why does not kill the login shell?
  kill -15 -1 && { sleep 30 || true; }
  warn "kill -9" || true
  exec kill -9 -1
fi
