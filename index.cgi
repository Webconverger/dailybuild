#!/bin/sh

DIST=`echo "$QUERY_STRING" | sed -n 's/^.*d=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
if [ "$DIST" != "sid" ]
then
    DIST='lenny'
fi

VERSION=`date +%F.$DIST`

cat <<END
Cache-Control: no-cache
Content-Type: text/html

<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8" />
		<title>live build $VERSION</title>
        <link rel="stylesheet" type="text/css" href="http://debian-live.alioth.debian.org/images/style.css" />
	</head>
<body>

<ul>
<li><a href="logs/">build log archive</a></li>
</ul>

END

if test `ls /tmp/$DIST.* | wc -l` -gt 0
then

	echo "<h1>BUILD IN PROGRESS !</h1>"

else

	if [ -e logs/$VERSION.txt ]
	then
		echo "<h1>BUILD $VERSION ALREADY EXISTS</h1>"
	else
		sudo /srv/web/build.webconverger.com/build.sh $DIST &> logs/$VERSION.txt &
	fi

fi

cat <<END
<p>Build log @
<a href="logs/$VERSION.txt">$VERSION.txt</a>
</p>

<pre>
$(uname -a)
$(lh --version | head -n1)
</pre>

</body>
</html>
END
