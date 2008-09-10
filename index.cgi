#!/bin/sh
VERSION="mini.$(date +%F)"

cat <<END
Cache-Control: no-cache
Content-Type: text/html

<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8" />
		<title>live build $VERSION</title>
        <link rel="stylesheet" href="http://webconverger.com/style.css" type="text/css">
	</head>
<body>

END

if [ $(ls /tmp/live.* 2> /dev/null | wc -l) -gt 0 ]
then

	echo "<h1>BUILD IN PROGRESS !</h1>"
	echo "<p>Only one build at a time :)</p>"

else

    if [ $(ls imgs/$VERSION.* 2> /dev/null | wc -l) -gt 0 ]
    then
        echo "<h1><a href='/imgs/'>BUILD $VERSION FOUND</a></h1>"
    else
        echo "<h1 style='color: red;'>NO BUILD $VERSION FOUND</h1>"
    fi

fi

if test -e logs/$VERSION.txt
then
    echo "<h2>Log file:<a href=\"logs/$VERSION.txt\">$VERSION.txt</a></h2>"
fi

cat <<END
<pre>
$(lh --version | head -n1)
$(uptime)
$(free -m)
</pre>

<ul>
<li><a href="http://git.webconverger.org/?p=build.git">CGI source code</a></li>
<li><a href="http://git.webconverger.org/?p=build.git;a=blob_plain;f=README">README</a></li>
</ul>

</body>
</html>
END
