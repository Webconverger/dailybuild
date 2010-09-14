#/bin/bash
. $(dirname $0)/config
echo $LOG

$(dirname $0)/build.sh &> $LOG
