#!/bin/sh
MIRROR="69.90.119.57"
DIST=${1:-sid}
TEMPDIR="$(mktemp -d -t $DIST.XXXXXXXX)"

set -ex

mailerror () {
echo "build failed" | mail -a 'From: build.webconverger.com <hendry@webconverger.com>' -s "$DIST failed" kai.hendry@gmail.com
exit 1
}

echo Setting up cleanup trap for $DIST at $TEMPDIR
trap "cd $TEMPDIR; sudo lh clean --purge; sudo rm -rf $TEMPDIR" 0 1 2 3 9 15

cd $TEMPDIR

lh --version | head -n1
wget -q -O- http://${MIRROR}/debian/project/trace/ftp-master.debian.org

lh_config -a i386 -d $DIST -p standard-x11 -m http://$MIRROR/debian --debug

find config/ -type f | while read FILENAME
do
   while read LINE
   do
       echo "${FILENAME}:${LINE}"
   done < $FILENAME
done

time sudo lh build || mailerror
ls -lah
