#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

interval=${interval:-5}
length=${length:-3}
csv=./snowbridge.csv

[ -f "$csv" ] || echo "0,0,0,0" > $csv

while true
do
    clear
    echo Last $length snowbridge calls:
    tail -n $length $csv
    echo
    counters=$(./snowbridge.counters.sh)
    echo Good Events Sent: $(cut -d, -f1 <<< $counters).
    echo Bad Events Sent: $(cut -d, -f2 <<< $counters).
    sleep $interval
done
