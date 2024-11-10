#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
BASE_DIR=$PWD

SNOWBRIDGE_PATH=${SNOWBRIGE_PATH:-/opt/snowplow}
SNOWBRIDGE_CONFIG=${SNOWBRIDGE_CONFIG:-}
PROCESSOR_SLEEP=${PROCESSOR_SLEEP:-10}
DATA_DIR=${DATA_DIR:-$BASE_DIR/data}

SNOWBRIDGE_CSV=$DATA_DIR/snowbridge.csv
SNOWBRIDGE_LOG=$DATA_DIR/snowbridge.log
MSG_SENT_FILE=$DATA_DIR/snowbridge.sent
DATA_TSV=$DATA_DIR/micro.tsv

export PATH=$SNOWBRIDGE_PATH:$PATH

zero_sent() { echo 0 > $MSG_SENT_FILE; }

[ -f $MSG_SENT_FILE ] || zero_sent

while true
do
    if [ -f $DATA_TSV ]
    then
        timestamp=$(date +%s)
        start=$(( $(<$MSG_SENT_FILE) + 1 ))
        echo At $timestamp: sending data from $DATA_TSV to snowbridge, starting from line $start.
        snowbridge_log=$SNOWBRIDGE_LOG.$timestamp
        {
            sed -n "$start,\$p" $DATA_TSV |
            snowbridge 2>&1 |
            tee -a $snowbridge_log |
            grep -oP '(?<=,|^)MsgSent:\K\d+' > $MSG_SENT_FILE
        } || {
            echo -e snowbridge reported a failure: "\n$(<$snowbridge_log)"
            zero_sent
        }
        echo "$(<$MSG_SENT_FILE)" messages were processed.
        echo "$timestamp,$(< $MSG_SENT_FILE)" >> $SNOWBRIDGE_CSV
        more_sent=$(<$MSG_SENT_FILE)
        echo $(( start - 1 + more_sent )) > $MSG_SENT_FILE
    else
        echo File $DATA_TSV is not available.
    fi
    echo Waiting $PROCESSOR_SLEEP seconds to run snowbridge again ...
    sleep $PROCESSOR_SLEEP
done
