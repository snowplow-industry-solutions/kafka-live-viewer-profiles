#!/usr/bin/env bash
cd $(dirname $0)

./terraform.sh png
docker-asciidoctor-builder
