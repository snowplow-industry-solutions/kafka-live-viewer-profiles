#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

interval=${interval:-5}
length=${length:-3}
csv=./snowbridge.csv

[ -f "$csv" ] || echo "0,0,0" > $csv

while true
do
    clear
    echo Last $length snowbridge calls:
    tail -n $length $csv
    echo
    echo Total processed: $(./snowbridge.sent.sh) events.
    sleep $interval
done
