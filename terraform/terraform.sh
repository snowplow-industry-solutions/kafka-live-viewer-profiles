#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

auto_approve=${auto_approve:-true}

workspace=$(realpath ..)
this_dir=/workspace/${PWD##*/}
docker_image=terraform-plus:latest

__docker-build() {
  [ "${1:-}" = force ] && rm -f .image-built
  [ -f .image-built ] || {
    docker build -t $docker_image .
    touch .image-built
  }
}

__docker-run() {
  local f=$workspace/.env
  [ -f "$f" ] || { echo File $f is unavailable. Aborting!; exit 1; }
  export $(grep ^AWS_ "$f" | xargs)
  __docker-build
  docker run \
    --rm \
    -it \
    -u "$(id -u):$(id -g)" \
    -w $this_dir \
    -v "$workspace:/workspace" \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    $docker_image "$@"
}

__apply() {
  local aa
  ! $auto_approve || aa=--auto-approve
  __docker-run apply ${aa:-} "$@"
}

__console() {
  additional_args=-it __docker-run console
}

__destroy() {
  local aa
  ! $auto_approve || aa=--auto-approve
  __docker-run destroy ${aa:-} "$@"
}

__fmt() {
  __docker-run fmt "$@"
}

__graph() {
  __docker-run graph "$@"
}

__init() {
  __docker-run init "$@"
}

__png() {
  __graph > terraform.dot
  dot -Tpng $this_dir/terraform.dot > terraform.png
}

__plan() {
  __docker-run plan "$@"
}

__validate() {
  __docker-run validate "$@"
}

dot() {
  docker run \
    --rm ${additional_args:-} \
    -u "$(id -u):$(id -g)" \
    -w $this_dir \
    -v "$workspace":/workspace \
    --entrypoint dot \
    $docker_image "$@"
}

help() {
  cat <<EOF
Usage: $0 [docker-build|docker-run|apply|destroy|fmt|plan|validate|...]
EOF
  exit 0
}

! [ $# = 0 ] || help
fn=__$1
shift
if type $fn &> /dev/null
then
  $fn "$@"
else
  ! [[ $fn =~ help ]] || help
  case "${fn#__}" in
    --version)
      __docker-run --version
      ;;
    *)
      echo ERROR: There isn\'t a function $fn defined in $0
      exit 1
  esac
fi
