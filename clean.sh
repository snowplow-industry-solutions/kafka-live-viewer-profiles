#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
BASE_DIR=$(basename $PWD)

echo NOTE: You are expected to run this script with containers not running.

echo Removing containers ...
docker compose rm --volumes || :

echo Removing volumes ...
for volume in zookeeper_data zookeeper_logs kafka_data kafka_logs
do
    echo Removing volume ${BASE_DIR}_$volume ...
    docker volume rm ${BASE_DIR}_$volume || :
done
yes | docker volume prune || :

./data/clean.sh all

(cd java-consumer; ./gradlew clean) || :
