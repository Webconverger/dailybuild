. $(dirname $0)/config
if test -e $LOG
then
    echo $LOG build already run?
else
    sudo $(dirname $0)/build.sh $BUILDID  &> $LOG
fi
