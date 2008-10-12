#!/bin/sh

cat <<END
Cache-Control: no-cache
Content-Type: text/html

<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8" />
		<title>Webconverger daily builds on $(hostname)</title>
        <link rel="stylesheet" href="http://webconverger.com/style.css" type="text/css">
	</head>
<body>

END

cat <<END
<pre>
$(lh --version | head -n1)
$(uptime)
$(free -m)
$(df -h)
</pre>

<ul>
<li><a href="imgs/">Daily built images</a></li>
<li><a href="logs/">Build logs</a></li>
<li><a href="http://git.webconverger.org/?p=build.git">CGI source code</a></li>
<li><a href="http://git.webconverger.org/?p=build.git;a=blob_plain;f=README">README</a></li>
</ul>

</body>
</html>
END
