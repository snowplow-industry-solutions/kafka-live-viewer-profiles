#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
BASE_DIR=$(basename $PWD)

echo NOTE: You are expected to run this script with containers not running.

echo Removing containers ...
docker compose rm --volumes || :

for volume in zookeeper_data zookeeper_logs kafka_data kafka_logs
do
    echo Removing volume ${BASE_DIR}_$volume ...
    docker volume rm ${BASE_DIR}_$volume || :
done

./data/clean.sh all
