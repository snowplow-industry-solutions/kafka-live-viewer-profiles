#!/usr/bin/env bash
cd $(dirname $0)
terraform_dir=${terraform_dir:-../../terraform}

$terraform_dir/terraform.sh png
mkdir -p ../images/terraform/
mv $terraform_dir/terraform.png ../images/terraform
rsync -a ../images/terraform/ images/

# https://gist.github.com/paulojeronimo/95977442a96c0c6571064d10c997d3f2
docker-asciidoctor-builder "$@"
