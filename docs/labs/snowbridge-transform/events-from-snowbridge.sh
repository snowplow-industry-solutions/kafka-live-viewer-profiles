#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

cat ${input:-output.6.txt} |
jq -s '.[] | [ .collector_tstamp, .event_id, .event_name, .viewer_id, .adsClicked, .adsSkipped, .adId, .video_ts ] | @csv' -r |
tr -d '"'
