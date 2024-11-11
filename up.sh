#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

echo Starting containers ...
docker compose up -d

./logs.sh
