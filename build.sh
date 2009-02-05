#!/bin/sh -ex
. $(dirname $0)/config
NAME=$1
TYPE=$(echo $NAME | awk -F . '{print $1}')
TEMPDIR="$(mktemp -d -t $NAME.XXXXXXXX)" || exit 1
echo Build type: $TYPE

if test "$(id -u)" -ne "0"
then
    echo "Super user required :-)" >&2
    exit 1
fi

mailerror () {
echo BUILD FAILED at $NAME
echo "$LOG" |
mail -a 'From: hendry@webconverger.com' -s "failed" kai.hendry@gmail.com
exit 1
}

if test ! $DEBUG # Whilst debugging we might want to inspect the detritus
then
    trap "cd $TEMPDIR/config-webc/$TYPE; lh clean --purge; rm -vrf $TEMPDIR" 0 1 2 3 9 15
fi

chmod a+rx $TEMPDIR && cd $TEMPDIR

mount # To check in case /proc is mounted already

echo Live Helper Version:
dpkg --status live-helper | egrep "^Version" | awk '{print $2}'

# To check what version our sources are
wget -q -O- http://${MIRROR}/debian/project/trace/ftp-master.debian.org

# Live helper configuration (Webconverger)
git clone git://git.debian.org/git/debian-live/config-webc.git

cd config-webc/$TYPE

# info about the git repo
git rev-parse HEAD
git describe --all

#find config/ -type f | while read FILENAME
#do
#   while read LINE
#   do
#       echo "${FILENAME}:${LINE}"
#   done < $FILENAME
#done

lh_config
time lh_build || mailerror
echo FINISH $?

ls -lah # Move build into output directory
for f in binary.*; do mv "$f" "$OUTPUT/$NAME.${f##*.}"; done

if test $USB
then
	# Lets build USB now too
	sed -i 's/\(^LH_BOOTLOADER.*\)/#\1/' config/binary
	echo 'LH_BINARY_IMAGES="usb-hdd"' >> config/binary
	sed -i 's/\(^LH_SOURCE.*\)/#\1/' config/source # we've compiled sources already by default
	lh clean --binary

	echo "Building USB image"
	time lh binary || mailerror
	ls -lah
	for f in binary.*; do mv "$f" "$OUTPUT/$NAME.${f##*.}"; done
fi

if test -e source.tar.gz # If LH_SOURCE is enabled
then
	mv source.tar.gz "$OUTPUT/$NAME.tar.gz"
fi

chown -R www-data:www-data $OUTPUT
