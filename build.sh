#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

echo Building containers ...
docker compose build
