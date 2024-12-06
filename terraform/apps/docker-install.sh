#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)/../..

bash <(curl -fsSL https://get.docker.com)
sudo usermod -aG docker $USER
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

f=terraform/apps/compose.yaml
echo Moving $f to $PWD ...
mv $f .

newgrp docker <<'EOF'
echo Building images ...
./build.sh &> /dev/null

show_logs=false ./up.sh
EOF
