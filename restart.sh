#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

./down.sh "$@"
./clean.sh
./build.sh "$@"
./up.sh "$@"
