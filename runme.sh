BUILDID=$(date --rfc-3339=date)
LOG=/srv/www/build.webconverger.org/output/$BUILDID.txt
if test -e $LOG
then
    echo $LOG build already run?
else
    sudo $(dirname $0)/build.sh $BUILDID  &> $LOG
fi

