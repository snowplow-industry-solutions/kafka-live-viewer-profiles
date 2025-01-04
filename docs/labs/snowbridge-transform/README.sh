#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

ln -sf data/samples/micro.1.tsv data.tsv
./data/tsv-debug.sh --print-field-names < data.tsv > data.tsv.txt
s=events-from-snowplow.sh; ./$s > $s.txt
./run.sh 6
s=events-from-snowbridge.sh; ./$s > $s.txt

# https://gist.github.com/paulojeronimo/95977442a96c0c6571064d10c997d3f2
docker-asciidoctor-builder "$@"
