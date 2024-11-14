#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

echo Stoping containers ...
docker compose down
