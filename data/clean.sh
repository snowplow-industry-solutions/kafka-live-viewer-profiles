#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

echo Removing existing data in $PWD ...
rm -f msg_sent snowbridge.{csv,log*,sent}
! [ "${1:-}" = all ] || rm -f micro.tsv
