#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

plantuml_image=plantuml/plantuml
puml_file=architecture.puml
output_dir=images

docker run -it --rm \
  -u $(id -u):$(id -g) \
  -v $(pwd):/data \
  $plantuml_image \
  plantuml -tpng /data/$puml_file -o /data/$output_dir

echo Diagrams generated successfully in \"${0%/*.sh}/$output_dir\" directory.
