#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
csv=snowbridge.csv
! [ -f $csv ] || awk -F',' '{sum += $3} END {print sum}' $csv
