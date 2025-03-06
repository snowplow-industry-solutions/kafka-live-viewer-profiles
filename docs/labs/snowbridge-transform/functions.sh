#!/usr/bin/env bash

before-build-docs() {
  ln -sf data/samples/micro.1.tsv data.tsv
  ./data/tsv-debug.sh --print-field-names < data.tsv > data.tsv.txt

  local s
  s=events-from-snowplow.sh; ./$s > $s.txt

  ./run.sh 6
  s=events-from-snowbridge.sh; ./$s > $s.txt
}
