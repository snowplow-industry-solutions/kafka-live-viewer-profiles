#!/usr/bin/env bash

show_logs=${show_logs:-true}

list_services() { yq -r '.services | keys[]' compose.$1.yaml | paste -sd ' ' -; }

localstack-services() { list_services localstack; }
aws-resources-services() { list_services aws-resources; }
kafka-services() { list_services kafka; }
snowplow-services() { list_services snowplow; }
apps-services() { list_services apps; }

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

! [[ "${1:-}" =~ -services$ ]] || set -- $($1)
