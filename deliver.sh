#img=mini.2009-03-30.4.3
release=$2
output=/srv/www/download.webconverger.org

[ -e output/$1-iso.iso ] || exit

rsync -P output/$1-iso.iso $output/webc-$release.iso
rsync -P output/$1-usb.img $output/webc-$release.img
rsync -P output/$1-iso.packages $output/webc-$release.txt

cd $output
sha1sum webc-$release.iso webc-$release.img >> $output/webc-$release.txt
md5sum webc-$release.iso webc-$release.img >> $output/webc-$release.txt
