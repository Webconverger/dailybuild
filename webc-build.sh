#/bin/bash
. $(dirname $0)/config

$(dirname $0)/build.sh &> $LOG
