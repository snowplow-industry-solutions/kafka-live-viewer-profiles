#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

[ "${1:-}" ] && container=$1
container=${container:-}

[ "${container:-}" ] &&
    container=${container%/}
    echo -n Showing logs for $container. ||
    echo -n Showing logs for all containers.

echo ' Press' 'Ctrl+C' to free your terminal ...

docker compose logs ${container:-} -f
