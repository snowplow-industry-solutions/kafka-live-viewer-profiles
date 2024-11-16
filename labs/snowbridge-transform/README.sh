#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

# docker-asciidoctor-builder is here:
# https://gist.github.com/paulojeronimo/95977442a96c0c6571064d10c997d3f2

BUILD_DIR=. \
GENERATE_PDF=${GENERATE_PDF:-false} \
HTML_NAME=README.html \
PDF_NAME=README.pdf \
docker-asciidoctor-builder "$@"
