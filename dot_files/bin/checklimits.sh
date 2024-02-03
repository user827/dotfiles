#!/bin/bash
set -eu

paste <(sort /proc/self/limits | grep 'open files\|pending signals\|processes' \
              | cut -c27-38)        \
      <(i=$(whoami)
        lsof -n -u "$i" 2> /dev/null |
             tail -n +2 |
             awk '{print $9}' |
             wc -l
        ps -u "$i" -o pid= |
             xargs printf "/proc/%s/status\n" |
             xargs grep -s 'SigPnd' |
             sed 's/.*\t//' |
             paste -sd+ |
             bc
        ps --no-headers -U "$i" -u "$i" u | wc -l ; ) \
      <(sort /proc/self/limits | grep 'open files\|pending signals\|processes' \
                   | cut -c1-19) |
while read -r a b name ; do
    printf '%3i%%  %s\n' $((${b}00/a)) "$name"
done
