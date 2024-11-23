#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

container=${1:-}

[ "${container:-}" ] && {
    container=${container%/}
    echo Stopping $container ... 
    export container
} || echo Stopping containers ...

docker compose down ${container:-}
