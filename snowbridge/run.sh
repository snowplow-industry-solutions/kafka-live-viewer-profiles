#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)
BASE_DIR=$PWD

# You may want to configure this variable in a compose.yaml file:
CALLER_SLEEP=${CALLER_SLEEP:-10}

# You can maybe configure these variables. But, you will need to adjust the Dockerfile:
DATA_DIR=${DATA_DIR:-$BASE_DIR/data}
SNOWBRIDGE_PATH=${SNOWBRIGE_PATH:-/opt/snowplow}

# The following are internal variables. You can configure it only here:
SNOWBRIDGE_CSV=$DATA_DIR/snowbridge.csv
COUNT_FILE=$DATA_DIR/snowbridge.count
DATA_TSV=$DATA_DIR/micro.tsv

export PATH=$SNOWBRIDGE_PATH:$PATH

[ -f $COUNT_FILE ] || echo 0 > $COUNT_FILE

echo \"Snowbridge caller\" started at $(date) ...

while true
do
    if [ -f $DATA_TSV ]
    then
        timestamp=$(date +%s)
        start=$(( $(<$COUNT_FILE) + 1 ))
        log=$DATA_DIR/snowbridge.$(date -I)/$timestamp.log
        logs_dir=${log%/*}; [ -d "$logs_dir" ] || mkdir -p "$logs_dir"
        if ! sent_and_failed=$(sed -n "$start,\$p" $DATA_TSV | snowbridge 2>&1 | tee $log | sed -n 's/.*MsgSent:\([0-9]\+\),MsgFailed:\([0-9]\+\).*/\1,\2/p')
        then
            error_dir=$logs_dir/error; [ -d $error_dir ] || mkdir -p $error_dir
            mv $log $error_dir
            echo -e At $timestamp, there was a failure. Check log file \"${error_dir##*/}/${log##*/}\".
            sleep $CALLER_SLEEP
            continue
        fi
        sent=$(cut -d, -f1 <<< $sent_and_failed)
        failed=$(cut -d, -f2 <<< $sent_and_failed)
        count=$(( sent + failed ))
        if [ $sent -gt 0 ] || [ $failed -gt 0 ]
        then
            echo At $timestamp, $sent messages were sent and $failed messages failed \(from $DATA_TSV starting from line $start\).
            echo $count > $COUNT_FILE
        else
            rm $log
            sleep $CALLER_SLEEP
            continue
        fi
        echo "$timestamp,$start,$sent_and_failed" >> $SNOWBRIDGE_CSV
        echo $(( start - 1 + count )) > $COUNT_FILE
    fi
    sleep $CALLER_SLEEP
done
