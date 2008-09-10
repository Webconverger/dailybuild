#!/bin/sh
MIRROR="ftp.egr.msu.edu"
DIST=${1:-sid}
TEMPDIR="$(mktemp -d -t live.$DIST.XXXXXXXX)" || exit 1

if test "$(id -u)" -ne "0"
then
    echo "not root" >&2
    exit 1
fi

mailerror () {
echo "http://build.webconverger.com/logs/`date +%F.$DIST`.txt" | mail -a 'From: build.webconverger.com <hendry@webconverger.com>' -s "$DIST failed" kai.hendry@gmail.com
exit 1
}

echo Setting up cleanup trap for $DIST at $TEMPDIR
trap "cd $TEMPDIR; lh clean --purge; rm -vrf $TEMPDIR" 0 1 2 3 9 15

chmod a+rx $TEMPDIR
cd $TEMPDIR

mount
lh --version | head -n1
wget -q -O- http://${MIRROR}/debian/project/trace/ftp-master.debian.org

lh_config -a i386 -d $DIST -p standard -m http://$MIRROR/debian --debug

find config/ -type f | while read FILENAME
do
   while read LINE
   do
       echo "${FILENAME}:${LINE}"
   done < $FILENAME
done

time lh build || mailerror

ls -lah
