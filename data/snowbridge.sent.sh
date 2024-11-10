#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
csv=snowbridge.csv
! [ -f $csv ] || awk -F',' '{sum += $2} END {print sum}' $csv
