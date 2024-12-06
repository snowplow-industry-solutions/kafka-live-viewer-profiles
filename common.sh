#!/usr/bin/env bash

show_logs=${show_logs:-true}

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
