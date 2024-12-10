#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

rsync -a ../images/paulojeronimo/ images/

case "${1:-}" in
    zip)
        $0
        echo Generating README.zip ...
        rm -f README.zip
        zip README.zip README.html README.pdf
        ;;
    *)
        # https://gist.github.com/paulojeronimo/95977442a96c0c6571064d10c997d3f2
        BUILD_DIR=. \
        GENERATE_PDF=true \
        HTML_NAME=README.html \
        PDF_NAME=README.pdf \
        docker-asciidoctor-builder -a git-commit=$(git rev-parse --short HEAD) "$@"
esac
