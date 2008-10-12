LOG=/srv/web/build.webconverger.com/logs/mini.$(date +%s).txt
if test -e $LOG
then
    echo $LOG build already run?
else
    sudo /srv/web/build.webconverger.com/build.sh &> $LOG
fi

