#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

echo Setting permissions for directory data ...
chmod 777 data

echo Starting containers ...
docker compose up -d

./logs.sh
