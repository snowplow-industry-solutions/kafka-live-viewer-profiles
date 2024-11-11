#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

echo Press 'Ctrl+C' to free your terminal ...
docker compose logs -f
