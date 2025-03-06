#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

mkdir -p ~/.lazydocker

docker run --rm -it \
  -u $(id -u):$(id -g) \
  -v ~/.lazydocker:/.config/jesseduffield/lazydocker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  lazyteam/lazydocker
