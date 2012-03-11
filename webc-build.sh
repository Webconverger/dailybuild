#/bin/bash
. $(dirname $0)/config
echo $LOG

$(dirname $0)/build.sh 2>&1 |tee $LOG
