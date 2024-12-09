#!/usr/bin/env bash
set -euo pipefail

LOCALSTACK=true

_aws() {
  $LOCALSTACK &&
    aws --endpoint-url=http://localhost.localstack.cloud:4566 "$@" ||
    aws "$@"
}

EXPECTED_STREAMS=("collector-good" "collector-bad" "enriched-good" "enriched-bad" "enriched-incomplete" "pii")
EXPECTED_TABLES=("snowbridge_checkpoints" "snowbridge_clients" "snowbridge_metadata")

check_streams() {
  local existing_streams
  existing_streams=$(_aws kinesis list-streams --query 'StreamNames' --output text)
  for stream in "${EXPECTED_STREAMS[@]}"
  do
    grep -q "$stream" <<< "$existing_streams" || return 1
  done
}

check_tables() {
  local existing_tables
  existing_tables=$(_aws dynamodb list-tables --query 'TableNames' --output text)
  for table in "${EXPECTED_TABLES[@]}"
  do
    grep -q "$table" <<< "$existing_tables" || return 1
  done
}

echo Waiting for AWS resources...

until check_streams && check_tables
do
  echo Resources not available yet, retrying in 5s ...
  sleep 5
done

echo All required resources are available.
