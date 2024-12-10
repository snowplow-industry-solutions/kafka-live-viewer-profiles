#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

awk -F':' '
/collector_tstamp/ {
    collector_tstamp = substr($0, index($0, $2))
    next
}
/event_id/ {
    event_id = substr($0, index($0, $2))
    next
}
/event_name/ {
    print collector_tstamp "," event_id "," substr($0, index($0, $2))
}' data.tsv.txt |
grep -E '(play_event|pause_event|ping_event|end_event|ad_break_start_event|ad_break_end_event)'
