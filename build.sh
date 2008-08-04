#!/bin/sh
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

lh_config -d $DIST -b usb-hdd -p standard-x11
time sudo lh build || mailerror
ls -lah
