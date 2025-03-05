#!/usr/bin/env bash

show_logs=${show_logs:-true}

warn() {
  echo WARNING: "$@"
}

set-env() {
  local env_file=.env
  local project_dir=..

  if ! [ -f $env_file ] || [ -f .keep-warning ]
  then
    project_env_file=$project_dir/$(cd $project_dir; echo ../${PWD##*/})${env_file#./}
    if ! [ -f $env_file ] && [ -f $project_env_file ]
    then
      echo File $project_env_file found. Copying it to $env_file ...
      cp $project_env_file $env_file
      rm -f .keep-warning
    elif ! [ -f $env_file ] || [ -f .keep-warning ]
    then
      warn You forgot to configure the file $env_file!
      warn I\'m generating it from $env_file.sample. But ...
      warn ... you need to fix this or you\'ll experience some errors when deploying to AWS.
      echo
      touch .keep-warning
      sed 's/false/true/g' $env_file.sample > $env_file
    fi
  fi
}

list-services() {
  command -v yq &> /dev/null || {
    echo Install yq before using this option!
    exit 1
  }
  yq -r '.services | keys[]' compose.$1.yaml | paste -sd ' ' -
}

list-available-services() {
  declare -F | sed -n 's/.*_\(.*\)-services.*/\1/p'
  exit 0
}

set-services() {
  services=
  [ $# = 0 ] || {
    for service in "$@"
    do
      services="${services:-} ${service%/}"
    done
    services=$(echo -n $services)
  }
}

show-services() {
  local op=$1
  [ "${services:-}" ] &&
    echo $op services \($services\) ... ||
    echo $op all services ...
}

set-env
for service in compose.*.yaml
do
  service=$(cut -d. -f2 <<< $service)
  eval "_$service-services() { list-services $service; }"
done
! [ "${1:-}" = services ] || list-available-services
! [[ "${1:-}" =~ -services$ ]] || set -- $(_$1)
