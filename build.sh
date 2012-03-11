#!/bin/bash

echo $PATH

if test "$(id -u)" -ne "0"
then
    echo "Super user required" >&2
    exit 1
fi

. $(dirname $0)/config

NAME=$1

if test -z "$NAME"
then
	NAME=$BUILDID
fi

TEMPDIR="$(mktemp -d -t $NAME.XXXXXXXX)" || exit 1

mailerror () {
echo BUILD FAILED at $NAME
echo "$LOG" |
mail -a 'From: hendry@webconverger.com' -s "failed" kai.hendry@gmail.com
exit 1
}

if test "$DEBUG"
then
	echo DEBUG MODE - $TEMPDIR needs to be manually deleted
else
	trap "cd $TEMPDIR/Debian-Live-config/webconverger; lb clean --purge; rm -vrf $TEMPDIR" 0 1 2 3 9 15
fi

chmod a+rx $TEMPDIR && cd $TEMPDIR

mount

if test "$(/sbin/losetup -a | wc -l)" -gt 0
then
	echo Unclean mounts!
	losetup -a
	exit
fi

echo "Debian Live, live-build version: "
dpkg --status live-build | egrep "^Version" | awk '{print $2}'

# Live helper configuration (Webconverger)
git clone git://github.com/Webconverger/Debian-Live-config.git

cd Debian-Live-config/webconverger

# info about the git repo
git rev-parse HEAD

# http://webconverger.org/upgrade/
make chroot

test -f binary-hybrid.iso || exit

mv binary-hybrid.iso "${OUTPUT}/${NAME}.iso"
for f in binary.*; do mv "$f" "${OUTPUT}/${NAME}.${f##*.}"; done
echo "Redirect /latest.img /${NAME}.iso" > $OUTPUT/.htaccess
echo "Redirect /latest.iso /${NAME}.iso" >> $OUTPUT/.htaccess
for s in source.*; do mv "$s" "${OUTPUT}/src-${NAME}.${s##*.}"; done

chown -R www-data:www-data $OUTPUT

test "$DEBUG" = "" && rm -rf $TEMPDIR
