#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
rm -f msg_sent snowbridge.{csv,log*,sent}
! [ "${1:-}" = all ] || rm -f micro.tsv
