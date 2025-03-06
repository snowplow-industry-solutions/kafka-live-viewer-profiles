#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

for build in $(find . -mindepth 2 -name build.sh ! -path './common/*')
do
    echo Running build.sh in ${build%/build.sh} directory ...
    $build
    echo
done