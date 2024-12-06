#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

./clean.sh "$@"
./build.sh "$@"
./up.sh "$@"
