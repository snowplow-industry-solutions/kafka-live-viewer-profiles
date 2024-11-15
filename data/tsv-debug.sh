#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
script=${0%.sh}.awk
if [ -t 0 ]
then
    if [ $# -eq 0 ]
    then
        sed -n '3,13p' $script |
        sed -e 's/^# //g' -e 's/^#$//g' -e 's/\.awk/.sh/g'
    else
        ./$script "$@"
    fi
else
    ./$script "$@" <<< "$(</dev/stdin)"
fi
