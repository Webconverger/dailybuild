#!/bin/sh
# Requires super user powers

export COLUMNS=80 # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=300990
MIRROR="ftp.egr.msu.edu"
set -ex
DIST=${1:-sid}
TEMPDIR="$(mktemp -d -t live.$DIST.XXXXXXXX)" || exit 1

mailerror () {
echo "http://build.webconverger.com/logs/`date +%F.$DIST`.txt" | mail -a 'From: build.webconverger.com <hendry@webconverger.com>' -s "$DIST failed" kai.hendry@gmail.com
exit 1
}

echo Setting up cleanup trap for $DIST at $TEMPDIR
trap "cd $TEMPDIR; lh clean --purge; rm -rf $TEMPDIR" 0 1 2 3 9 15

chmod a+rx $TEMPDIR # in order for index to check a build
cd $TEMPDIR

mount # check existing mounts
lh --version | head -n1
wget -q -O- http://${MIRROR}/debian/project/trace/ftp-master.debian.org

lh_config -a i386 -b usb-hdd -d $DIST -p standard-x11 -m http://$MIRROR/debian --debug

find config/ -type f | while read FILENAME
do
   while read LINE
   do
       echo "${FILENAME}:${LINE}"
   done < $FILENAME
done

time lh build || mailerror
ls -lah
