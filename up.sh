#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
source ./common.sh

set-services "$@"
show-services Starting

[ -f .env ] || sed 's/false/true/g' .env.example > .env

docker compose up ${services:-} -d

! $show_logs || ./logs.sh "$@"
