#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
source ../common/README.sh

build-docs "$@"
