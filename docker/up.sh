#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
source ./common.sh

set-services "$@"
show-services Starting

env_file=${env_file:-./.env}

[ -f $env_file ] || {
  project_env_file=../../${PWD##*/}${env_file#./}
  [ -f $project_env_file ] && {
    echo File $project_env_file found. Linking it to $env_file ...
    ln $project_env_file $env_file
  } || {
    echo WARNING: you forgot to configure the file $env_file!
    echo WARNING: you may experience some errors during execution in AWS environment ...
    sed 's/false/true/g' $env_file.example > $env_file
  }
}
unset env_file project_env_file

docker compose up ${services:-} --build -d

! $show_logs || ./logs.sh "$@"
