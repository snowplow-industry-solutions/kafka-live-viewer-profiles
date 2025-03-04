#!/usr/bin/env bash

show_logs=${show_logs:-true}

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

for service in compose.*.yaml
do
  service=$(cut -d. -f2 <<< $service)
  eval "_$service-services() { list-services $service; }"
done
! [ "${1:-}" = services ] || list-available-services
! [[ "${1:-}" =~ -services$ ]] || set -- $(_$1)
