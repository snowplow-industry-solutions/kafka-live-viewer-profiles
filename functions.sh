#!/usr/bin/env bash

SNOWPLOW_DEMO_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
[ -f $SNOWPLOW_DEMO_DIR/.env ] || cp $SNOWPLOW_DEMO_DIR/.env{.example,}

#https://hub.docker.com/r/hashicorp/terraform
terraform() {
  docker compose -f $SNOWPLOW_DEMO_DIR/compose.terraform.yaml "$@"
}
