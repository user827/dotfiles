#!/usr/bin/zsh

set -eu

proj=$(cd $1; pwd)
gitpid=$(mktemp git.XXXXXXX)
ladr=$2
shift 2

git daemon $@ --listen=$ladr --detach --base-path=$(cd $proj/..; pwd) \
  --export-all --pid-file=$gitpid $proj

echo $gitpid
exit 0



read -pExit?
echo Shutting down

kill $(< $gitpid)
rm $gitpid
