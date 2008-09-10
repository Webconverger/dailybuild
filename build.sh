#!/bin/sh -e
TYPE="mini"
MIRROR="ftp.egr.msu.edu"
TEMPDIR="$(mktemp -d -t live.XXXXXXXX)" || exit 1

if test "$(id -u)" -ne "0"
then
    echo "not root" >&2
    exit 1
fi

mailerror () {
echo BUILD FAILED at $(date)
echo "http://build.webconverger.com/logs/$(date +%F).txt" | mail -a 'From: build.webconverger.com <hendry@webconverger.com>' -s "failed" kai.hendry@gmail.com
exit 1
}

trap "cd $TEMPDIR/config-webc/$TYPE; lh clean --purge; rm -vrf $TEMPDIR" 0 1 2 3 9 15

chmod a+rx $TEMPDIR
cd $TEMPDIR

mount
lh --version | head -n1
wget -q -O- http://${MIRROR}/debian/project/trace/ftp-master.debian.org

git clone git://git.debian.org/git/debian-live/config-webc.git
cd config-webc/$TYPE

find config/ -type f | while read FILENAME
do
   while read LINE
   do
       echo "${FILENAME}:${LINE}"
   done < $FILENAME
done

time lh build || mailerror

for f in binary.*; do mv "$f" "/srv/web/build.webconverger.com/imgs/$TYPE.$(date +%F).${f##*.}"; done
