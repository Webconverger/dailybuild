#!/bin/sh

cat <<END
Cache-Control: no-cache
Content-Type: text/html

<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8" />
		<title>Penis length on $(hostname)</title>
        <link rel="stylesheet" href="http://webconverger.com/style.css" type="text/css">
	</head>
<body>

<h1>
END


echo `uptime|grep days|sed 's/.*up \([0-9]*\) day.*/\1\/10+/'; cat /proc/cpuinfo|grep '^cpu MHz'|awk '{print $4"/30 +";}';free|grep '^Mem'|awk '{print $3"/1024/3+"}'; df -P -k -x nfs -x smbfs | grep -v '(1k|1024)-blocks' | awk '{if ($1 ~ "/dev/(scsi|sd)"){ s+= $2} s+= $2;} END {print s/1024/50"/15+70";}'`|bc|sed 's/\(.$\)/.\1cm/'

cat <<END
</h1>

</body>
</html>
END
