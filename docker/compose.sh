#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

available-ops() {
  echo "build|down|lazy|logs|ps|up|stats"
}

help() {
  cat <<EOF
Usage:
$0 <$(available-ops)>
EOF
  exit 1
}

op=${1:-}
[ "$op" ] || help
shift

if [[ "$op" =~ ^($(available-ops))$ ]]
then
  sudo=
  [ "$op" = lazy ] && sudo=sudo
  $sudo ./$op.sh "$@"
else
  help
fi
