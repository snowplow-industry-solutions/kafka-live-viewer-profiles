#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
BASE_DIR=$PWD

# You may want to configure this variable in a compose.yaml file:
PROCESSOR_SLEEP=${PROCESSOR_SLEEP:-10}

# You can maybe configure these variables. But, you will need to adjust the Dockerfile:
DATA_DIR=${DATA_DIR:-$BASE_DIR/data}
SNOWBRIDGE_PATH=${SNOWBRIGE_PATH:-/opt/snowplow}

# The following are internal variables. You can configure it only here:
SNOWBRIDGE_CSV=$DATA_DIR/snowbridge.csv
SNOWBRIDGE_LOG=$DATA_DIR/snowbridge.log
MSG_SENT_FILE=$DATA_DIR/snowbridge.sent
DATA_TSV=$DATA_DIR/micro.tsv

export PATH=$SNOWBRIDGE_PATH:$PATH

send_zero_to() { echo 0 > $1; }

[ -f $MSG_SENT_FILE ] || send_zero_to $MSG_SENT_FILE

while true
do
    if [ -f $DATA_TSV ]
    then
        timestamp=$(date +%s)
        start=$(( $(<$MSG_SENT_FILE) + 1 ))
        snowbridge_log=$SNOWBRIDGE_LOG.$timestamp
        {
            sed -n "$start,\$p" $DATA_TSV |
            snowbridge 2>&1 |
            tee -a $snowbridge_log |
            grep -oP '(?<=,|^)MsgSent:\K\d+' > $MSG_SENT_FILE
        } || {
            echo -e snowbridge reported a failure: "\n$(<$snowbridge_log)"
            send_zero_to $MSG_SENT_FILE
        }
        total_sent="$(<$MSG_SENT_FILE)"
        if [ $total_sent -gt 0 ]
        then
            echo At $timestamp, $total_sent messages were processed from $DATA_TSV starting from line $start.
            echo "$timestamp,$total_sent" >> $SNOWBRIDGE_CSV
            echo $(( start - 1 + total_sent )) > $MSG_SENT_FILE
        fi
    fi
    sleep $PROCESSOR_SLEEP
done
