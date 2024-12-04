#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
zip_file=snowplow-demo.zip
rm -f $zip_file
zip -y -x \
  '.env' \
  '.git/*' \
  '.gitignore' \
  'aws-zip.sh' \
  'compose.yaml' \
  'compose.kafka.yaml' \
  'compose.snowplow.yaml' \
  'compose.terraform.yaml' \
  'enrich/*' \
  'iglu-client/*' \
  'images/*' \
  'labs/*' \
  'localstack/*' \
  'requirements.pdf' \
  'snowbridge/*' \
  'snowbridge.sh' \
  'stream-collector/*' \
  'terraform/*' \
  'README*' \
  -r $zip_file .
