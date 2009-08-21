#img=mini.
set -e
release=5.2
output=/srv/www/download.webconverger.org

rsync -P output/$1-iso.iso $output/webc-$release.iso
rsync -P output/$1-usb.img $output/webc-$release.img
rsync -P output/$1-iso.packages $output/webc-$release.txt

cd $output
echo sha1sum: >> $output/webc-$release.txt
sha1sum webc-$release.iso webc-$release.img >> $output/webc-$release.txt
echo md5sum: >> $output/webc-$release.txt
md5sum webc-$release.iso webc-$release.img >> $output/webc-$release.txt
