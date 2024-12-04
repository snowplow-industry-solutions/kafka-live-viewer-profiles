#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

[ $USER = ubuntu ] || {
  echo This script is intended to be run by the user ubuntu '(inside an AWS instance)'
  exit 1
}

bash <(curl -fsSL https://get.docker.com)
sudo usermod -aG docker $USER
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

mv compose.apps.incomplete.yaml compose.yaml

newgrp docker <<'EOF'
docker compose up -d
EOF
