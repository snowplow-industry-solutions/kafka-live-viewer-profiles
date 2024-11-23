#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

container=${1:-}

[ "${container:-}" ] && {
    container=${container%/}
    echo Starting $container ... 
    export container
} || echo Starting containers ...

[ -f .env ] || sed 's/false/true/g' .env.example > .env

docker compose up ${container:-} -d

./logs.sh
