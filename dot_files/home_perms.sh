#!/bin/sh
set -eu
homepath=$1

chmod 700 "$homepath"/.ssh
chmod 700 "$homepath"/.gnupg
[ -d "$homepath"/.anacron ] || mkdir "$homepath"/.anacron
