#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)/../..

zip_file=terraform/apps/snowplow-demo.zip

echo Generating $PWD/$zip_file ...

rm -f $zip_file
{
  find . -maxdepth 1 -name '*.sh' ! \( \
    -name README.sh -o \
    -name snowbridge.sh \
  \)
  find . \( \
    -name .env -o \
    -path './live-viewer-backend/*' -o \
    -path './live-viewer-frontend/*' -o \
    -path './terraform/apps/compose.yaml' -o \
    -path './terraform/apps/docker-install.sh' -o \
    -path './tracker-frontend/*' \
  \);
} | zip -q -y $zip_file -@
