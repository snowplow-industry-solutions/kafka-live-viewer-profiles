#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

help() {
    cat <<'EOF'
Usage examples:

$ ./run.sh # <- show this help
$ ./run.sh help # <- show this help

$ ./run.sh 1 # <- execute snowbridge using script.1.sh

$ export script_id=6 <- export this variable to skip specify the parameter to run.sh
$ ./run.sh # <- execute snowbridge using script.6.sh
EOF
    exit 0
}

[ "${1:-}" ] && script_id=$1 || [ "${script_id:-}" ] || help
! [ "${script_id:-}" = help ] || help

script=script.$script_id.js
[ -f $script ] || { echo File $script not found. Aborting!; exit 1; }
micro_id=${micro_id:-1}
micro_tsv=${micro_tsv:-../../data/samples/micro.$micro_id.tsv}

echo Running snowbridge configured with $script.

rm -f script.js output.txt

[ -f data.tsv ] || {
    echo Copying $micro_tsv to ./data.tsv and running snowpbridge with $script ...
    cp $micro_tsv ./data.tsv
    echo Generating data.tsv.txt ...
    cat data.tsv | ../../data/tsv-debug.sh --print-field-names > data.tsv.txt
}

cp $script script.js

#tag::docker[]
cat data.tsv | docker run --rm -i \
    --env ACCEPT_LIMITED_USE_LICENSE=yes \
    --mount type=bind,source=$(pwd)/config.hcl,target=/tmp/config.hcl \
    --mount type=bind,source=$(pwd)/script.js,target=/tmp/script.js \
    snowplow/snowbridge:2.4.2 > output.txt
#end::docker[]

case "$script_id" in
    4|5|6)
        #tag::data[]
        echo Saving output.txt to output.$script_id.txt.original
        mv output.txt output.$script_id.txt.original

        echo Generating an output.txt containing only the \"Data\" field ...
        cut -d, -f5- output.$script_id.txt.original | sed 's/^Data://g' > output.txt
        #end::data[]
        ;;
esac

ln -sf $script script.js

echo Copying output.$script_id.txt from output.txt and linking this file to it ...
cat output.txt > output.$script_id.txt
ln -sf output.$script_id.txt output.txt
