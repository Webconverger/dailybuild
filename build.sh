#!/bin/sh -ex
TYPE="mini"
MIRROR="mirror.webconverger.com"
OUTPUT="/srv/www/build.webconverger.org/output"
TEMPDIR="$(mktemp -d -t live.XXXXXXXX)" || exit 1
NAME=$TYPE.$1

if test "$(id -u)" -ne "0"
then
    echo "not root" >&2
    exit 1
fi

mailerror () {
echo BUILD FAILED at $NAME
echo "http://build.webconverger.com/logs/$NAME.txt" | mail -a 'From: build.webconverger.com <hendry@webconverger.com>' -s "failed" kai.hendry@gmail.com
exit 1
}

if test ! $DEBUG
then
    trap "cd $TEMPDIR/config-webc/$TYPE; lh clean --purge; rm -vrf $TEMPDIR" 0 1 2 3 9 15
fi

chmod a+rx $TEMPDIR
cd $TEMPDIR

mount # For debugging (in case /proc is mounted already)

lh --version | head -n1
dpkg -l live-helper

wget -q -O- http://${MIRROR}/debian/project/trace/ftp-master.debian.org

git clone git://git.debian.org/git/debian-live/config-webc.git

cd config-webc/$TYPE

if test $HOSTNAME = "hetty"
then
	git checkout -b hetty origin/hetty
fi

find config/ -type f | while read FILENAME
do
   while read LINE
   do
       echo "${FILENAME}:${LINE}"
   done < $FILENAME
done

echo "Building default (ISO)"
time lh build || mailerror

ls -lah
for f in binary.*; do mv "$f" "$OUTPUT/$NAME.${f##*.}"; done

# Lets build USB now too
sed -i 's/\(^LH_BOOTLOADER.*\)/#\1/' config/binary
echo 'LH_BINARY_IMAGES="usb-hdd"' >> config/binary
sed -i 's/\(^LH_SOURCE.*\)/#\1/' config/source # we've compiled sources already by default
lh clean --binary

echo "Building USB image"
time lh binary || mailerror

ls -lah
for f in binary.*; do mv "$f" "$OUTPUT/$NAME.${f##*.}"; done
if test -e source.tar.gz
then
	mv source.tar.gz "$OUTPUT/$NAME.tar.gz"
fi

chown -R www-data:www-data $OUTPUT
