#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

echo Removing existing data in $PWD ...
rm -f snowbridge.{csv,count}
find . -type d -name 'snowbridge.*' | xargs rm -rf
! [ "${1:-}" = all ] || rm -f micro.tsv
