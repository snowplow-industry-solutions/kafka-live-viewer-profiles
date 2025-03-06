#!/usr/bin/env bash

before-build-docs() {
  local terraform_dir=${terraform_dir:-../../terraform}

  echo Generating images/terraform.png ...
  $terraform_dir/terraform.sh png
  mv $terraform_dir/terraform.png ./images/
}
