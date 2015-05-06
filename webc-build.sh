#!/bin/bash -e

branch=${1:-master}
OUTPUT="/srv/www/build.webconverger.org"

sha=$(git ls-remote git://github.com/Webconverger/webc.git refs/heads/$branch)
shortsha=${sha:0:7}

if ls $OUTPUT/webc-$shortsha.*
then
	echo Already built!
	exit
fi

BUILDID=webconverger.$branch.$(date --rfc-3339=date)
LOG=$OUTPUT/$BUILDID.txt
echo Building $BUILDID ... logging to $OUTPUT/$BUILDID.txt

exec >$LOG 2>&1

figlet $branch $shortsha

test "$DEBUG" && echo $PATH

if test "$(id -u)" -ne "0"
then
    echo "Super user required" >&2
    exit 1
fi

TEMPDIR="$(mktemp -d -t $BUILDID.XXXXXXXX)" || exit 1

test "$DEBUG" || trap "rm -rf $TEMPDIR" EXIT

test "$DEBUG" && echo TEMPDIR $TEMPDIR

mailerror () {
echo BUILD FAILED at $BUILDID
echo "$LOG" |
mail -a 'From: hendry@webconverger.com' -s "$BUILDID failed" hendry+build@webconverger.com
exit 1
}

chmod a+rx $TEMPDIR && cd $TEMPDIR

test "$DEBUG" && mount

if test "$(/sbin/losetup -a | wc -l)" -gt 0
then
	echo Unclean mounts!
	losetup -a
	exit
fi

echo "Debian Live, live-build version: "
dpkg --status live-build | egrep "^Version" | awk '{print $2}'

git clone --depth 1 git://github.com/Webconverger/Debian-Live-config.git
cd Debian-Live-config/webconverger

# info about build config we have
git describe --always

# http://webconverger.org/upgrade/
make BRANCH=$branch

chown -R www-data:www-data $OUTPUT

mv live-image-i386.hybrid.iso $OUTPUT/webc-$shortsha.iso
echo -e "Options All\nOptions Indexes FollowSymLinks" > $OUTPUT/.htaccess
echo "Redirect /latest.iso /webc-$shortsha.iso" >> $OUTPUT/.htaccess
