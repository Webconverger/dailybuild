#!/bin/bash -e

OUTPUT="/srv/www/build.webconverger.org"

sha=$(git ls-remote git://github.com/Webconverger/webc.git refs/heads/master)
shortsha=${sha:0:7}

if ls $OUTPUT/webc-$shortsha.*
then
	echo Already built!
	exit
fi

BUILDID=webconverger.$(date --rfc-3339=date)

if test "$1"
then
	branch=$1
	BUILDID=webconverger.$branch.$(date --rfc-3339=date)
fi

LOG=$OUTPUT/$BUILDID.txt

exec >$LOG 2>&1

test "$branch" && figlet $branch

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
mail -a 'From: hendry@webconverger.com' -s "uk failed" kai.hendry@gmail.com
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

# Live helper configuration (Webconverger)
if test "$branch"
then
	git clone --depth 1 -b $branch git://github.com/Webconverger/Debian-Live-config.git
else
	git clone --depth 1 git://github.com/Webconverger/Debian-Live-config.git
fi

cd Debian-Live-config/webconverger

# info about the git repo
git describe --always

# http://webconverger.org/upgrade/
make deploy OUTPUT=$OUTPUT

chown -R www-data:www-data $OUTPUT
