#!/usr/bin/env bash
set -eoup pipefail
cd $(dirname $0)

container=${0##*/}
container=${container%.sh}

invalid-container() {
    echo Container "(${container:-})" is invalid!
    exit 1
}

case "$container" in
    backend | frontend) container=live-viewer-$container
esac

case "$container" in
    live-viewer-backend | \
    live-viewer-frontend | \
    snowbridge | \
    : ) : ;;
    *) invalid-container
esac

! [ "$container" = : ] || invalid-container

case "${1:-}" in
    build|up|down|logs|stats|top|start|stop|restart) op=$1 ;;
    *)
        cat <<EOF
Usage alternatives:

$ $0 build # <- Builds or rebuilds the $container container
$ $0 up # <- Starts the $container container
$ $0 up -d # <- Starts the $container container as a daemon
$ $0 logs # <- Shows the $container container logs
$ $0 logs -f # <- Follow log output for the $container container
$ $0 down # <- Stops the $container container
$ $0 stats # <- Shows statistics about the $container container
$ $0 top # <- Shows information about the $container container
$ $0 start # <- Starts a stoped $container container
$ $0 stop # <- Stops a started $container container
$ $0 restart # <- Restarts a started $container container
EOF
        exit 0
esac

shift || :

echo Running the following command:
set -x
docker compose $op $container "$@"
