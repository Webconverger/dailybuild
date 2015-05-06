rsync -P *.iso nl.webconverger.com:/srv/www/eu.download.webconverger.com/
rsync -P *.iso houston.dreamhost.com:na.download.webconverger.com/
aws --profile hsgpower s3 cp --acl public-read *.iso s3://as.download.webconverger.com
