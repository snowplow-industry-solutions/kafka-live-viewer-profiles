#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)/../..

this_dir=terraform/apps
zip_name=${zip_name:-'snowplow-demo.zip'}
zip_file=$this_dir/$zip_name

source ./$this_dir/common.sh

log PWD=$PWD
log Generating $zip_file ...

rm -f $zip_file
{
  find . -maxdepth 1 -name 'compose*.yaml'
  find . -maxdepth 1 -name '*.sh' ! -name README.sh
  find . \( \
    -name .env -o \
    -path './aws-resources/*' -o \
    -path './enrich/*' -o \
    -path './iglu-client/*' -o \
    -path './live-viewer-*/*' -o \
    -path './snowbridge/*' -o \
    -path './stream-collector/*' -o \
    -path './terraform/apps/common.sh' -o \
    -path './terraform/apps/install.sh' -o \
    -path './tracker-frontend/*' \
  \);
} | zip -q -y $zip_file -@
