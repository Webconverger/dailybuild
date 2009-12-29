#!/bin/sh -ex
if test "$(id -u)" -ne "0"
then
    echo "Super user required" >&2
    exit 1
fi

. $(dirname $0)/config

NAME=$1

if [ -z $NAME ]
then
	NAME=$BUILDID
fi

TYPE=$(echo $NAME | awk -F . '{print $1}')
TEMPDIR="$(mktemp -d -t $NAME.XXXXXXXX)" || exit 1
echo Build type: $TYPE

mailerror () {
echo BUILD FAILED at $NAME
echo "$LOG" |
mail -a 'From: hendry@webconverger.com' -s "failed" kai.hendry@gmail.com
exit 1
}

if test $DEBUG -eq 1
then
	echo DEBUG MODE
else
	trap "cd $TEMPDIR/config-webc/$TYPE; lh clean --purge; rm -vrf $TEMPDIR" 0 1 2 3 9 15
fi

chmod a+rx $TEMPDIR && cd $TEMPDIR

mount # To check in case /proc is mounted already

echo Live Helper Version:
dpkg --status live-helper | egrep "^Version" | awk '{print $2}'

# Live helper configuration (Webconverger)
git clone git://git.debian.org/git/debian-live/config-webc.git

cd config-webc/$TYPE

# info about the git repo
git rev-parse HEAD

lh config

lh build || mailerror
ls -lh
for f in binary.*; do mv "$f" "${OUTPUT}/${NAME}-usb.${f##*.}"; done
rm -f $OUTPUT/.htaccess
echo "Redirect /latest.img /${NAME}-usb.img" > $OUTPUT/.htaccess

	if ! ls -lh chroot/boot/*
	then
		echo There is a bug here. When run from cron, the script purges chroot/boot from /usr/share/live-helper/helpers/lh_bootstrap_cache
		echo
		echo This makes the next lh binary FAIL
		exit
	fi

if test $ISO
then
	echo Building ISO
	lh clean noautoconfig --binary
	lh config noautoconfig --source true -b iso --bootappend-live "quiet homepage=http://portal.webconverger.com/ nonetworking nosudo splash video=vesa:ywrap,mtrr vga=788 nopersistent"

	lh binary || mailerror

	for f in binary.*; do mv "$f" "$OUTPUT/${NAME}-iso.${f##*.}"; done
	echo "Redirect /latest.iso /${NAME}-iso.iso" >> $OUTPUT/.htaccess
fi

if test $SOURCE
then
	lh source
	mv source.list "$OUTPUT/$NAME.source.list"
	mv source.tar.gz "$OUTPUT/$NAME.tar.gz"
fi

chown -R www-data:www-data $OUTPUT
