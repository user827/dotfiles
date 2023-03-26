#!/bin/sh
set -eu

subject=$1

msg=$(systemctl --user status --full "$subject") || true

printf '%s\n' "Subject: Service failed: $(printf '%s' "$subject" | tr '\n' ' ')
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
$msg" | sendmail "$USER"
