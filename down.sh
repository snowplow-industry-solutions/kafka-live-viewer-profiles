#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

echo Stpoting containers ...
docker compose down
