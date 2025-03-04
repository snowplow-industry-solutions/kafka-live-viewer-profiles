#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

project_dir=${PWD##*/}

docker-asciidoctor-builder \
  -a project-dir=$project_dir \
  "$@"
