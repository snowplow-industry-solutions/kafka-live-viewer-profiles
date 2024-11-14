#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
csv=snowbridge.csv
! [ -f $csv ] || awk -F',' '{sent += $3; failed += $4} END {print sent","failed}' $csv
