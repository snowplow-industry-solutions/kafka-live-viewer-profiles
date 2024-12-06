#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
BASE_DIR=$(basename $PWD)

./down.sh "$@"

echo Removing containers ...
docker compose rm --volumes || :

echo Removing volumes ...
for volume in zookeeper_data zookeeper_logs kafka_data kafka_logs
do
    echo Removing volume ${BASE_DIR}_$volume ...
    docker volume rm ${BASE_DIR}_$volume || :
done
yes | docker volume prune || :

echo Removing built images ...
docker compose down --rmi local
