#!/usr/bin/env bash
set -eoup pipefail
cd $(dirname $0)

image=${0##*/}
image=${image%.sh}

case "$image" in
    backend | frontend) image=live-viewer-$image
esac

case "$image" in
    live-viewer-backend | \
    live-viewer-frontend | \
    : ) : ;;
    *)
        echo Image "(${image:-})" is invalid!
        exit 1
esac

case "${1:-}" in
    up|down|logs|stats|top|start|stop|restart) op=$1 ;;
    *)
        cat <<EOF
Usage alternatives:

$ $0 up # <- Starts the $image container
$ $0 up -d # <- Starts the $image container as a daemon
$ $0 logs # <- Shows the $image container logs
$ $0 logs -f # <- Follow log output for the $image container
$ $0 down # <- Stops the $image container
$ $0 stats # <- Shows statistics about the $image container
$ $0 top # <- Shows information about the $image container
$ $0 start # <- Starts a stoped $image container
$ $0 stop # <- Stops a started $image container
$ $0 restart # <- Restarts a started $image container
EOF
        exit 0
esac

shift || :

echo Running the following command:
set -x
docker compose $op $image "$@"
