#!/usr/bin/env bash

common_dir=${BASH_SOURCE[0]}
common_dir=${common_dir%/README.sh}

rsync -a --exclude=build.sh $common_dir .

for f in .gitignore .docker-asciidoctor-builder README.css
do
  [ -f $f ] || {
    echo Copying $f '(from common)' to .
    cp common/$f .
  }
done

additional_functions=./functions.sh
! [ -f $additional_functions ] || {
  echo Loading additional functions "(from $additional_functions)" ...
  source $additional_functions
}

build-docs() {
  local project_dir=${PWD##*/}

  ! type before-build-docs &> /dev/null || before-build-docs

  # https://gist.github.com/paulojeronimo/95977442a96c0c6571064d10c997d3f2
  docker-asciidoctor-builder \
    -a git-commit=$(git rev-parse --short HEAD) \
    -a project-dir=$project_dir \
    "$@"

  ! type after-build-docs &> /dev/null || after-build-docs
}
