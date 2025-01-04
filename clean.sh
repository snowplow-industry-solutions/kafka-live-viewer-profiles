#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

[ "${1:-}" ] || set -- local
case "$1" in
  local | all) :;;
  *) echo Invalid option: $1
esac

yes | docker volume prune || :

echo Removing $1 images ...
docker compose down --rmi $1
