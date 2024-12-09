#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)/../..

this_dir=terraform/apps
instance_name=${1:-localhost}

source ./$this_dir/common.sh

# ######################
# packages installation
log Installing additional packages ...
sudo apt install -y tree &> /dev/null

# ###################
# docker installation
log Installing docker ...
bash <(curl -fsSL https://get.docker.com) &> /dev/null
sudo usermod -aG docker $USER
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# ##############################################
# required configuration (before running docker)
compose=compose.yaml
compose_localstack=compose.localstack.yaml
log Removing file $compose_localstack ...
rm -f $compose_localstack
log Removing $compose_localstack include from $compose ...
sed -i "/$compose_localstack/d" $compose

if [ $instance_name != localhost ]
then
  frontend_js=live-viewer-frontend/public/js/scripts.js
  log Configuring URL in $frontend_js to $instance_name ...
  sed -i "s,\(ws://\)\(localhost\),\1$instance_name,g" $frontend_js
fi

dotenv=.env
log Removing AWS_ENDPOINT_URL from $dotenv ...
sed -i '/AWS_ENDPOINT_URL/d' $dotenv

for f in \
  enrich/enrich.hocon \
  snowbridge/config.hcl \
  stream-collector/config.hocon
do
  log Removing LocalStack configurations from $f ...
  sed -i '/localstack\.cloud/d' $f
done

# ################
# docker execution
newgrp docker <<EOF
source $this_dir/common.sh

log Building docker images ...
./build.sh &> /dev/null

log Starting docker containers ...
show_logs=false ./up.sh &> /dev/null
EOF

# ####
# done
log Finished successfully.
