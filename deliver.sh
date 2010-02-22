set -e
release=6.1
output=/srv/www/download.webconverger.org

rsync -P output/$1.iso $output/webc-$release.iso
rsync -P output/$1.packages $output/webc-$release.txt
rsync -P output/$1.tar.gz $output/webc-$release.tar.gz

cd $output
echo sha1sum: >> $output/webc-$release.txt
sha1sum webc-$release.iso >> $output/webc-$release.txt
echo md5sum: >> $output/webc-$release.txt
md5sum webc-$release.iso >> $output/webc-$release.txt
