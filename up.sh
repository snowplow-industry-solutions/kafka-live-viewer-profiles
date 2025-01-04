#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
source ./common.sh

set-services "$@"
show-services Starting

f=./.env; [ -f $f ] || {
  g=../${PWD##*/}${f#./}
  [ -f $g ] && {
    echo File $g found. Linking it to $f ...
    ln $g $f
  } || {
    echo WARNING: you forgot to configure the file $f!
    echo WARNING: you may experience some errors during execution in AWS environment ...
    sed 's/false/true/g' $f.example > $f
  }
}
unset f g

docker compose up ${services:-} -d

! $show_logs || ./logs.sh "$@"
