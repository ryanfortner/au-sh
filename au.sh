#!/bin/bash

# define variables
PKGDIR="/root/raspbian-addons/debian/pool/"
PKGDIRA="/root/raspbian-addons/debian/"
GPGPATH="/root/gpgpass"
EMAILPATH="/root/email"
DATEA="$(date)"

echo $DATEA

function error {
  echo -e "\e[91m$1\e[39m"
  exit 1
}

if [ ! -f ${GPGPASS} ]; then
  error "gpg file not detected"
fi

if [ ! -f ${EMAIL} ]; then
  error "email file not detected"
fi

mkdir -p ~/dlfiles
cd ~/dlfiles
rm -rf *

echo "Updating VSCodium"
LATEST=`curl -s https://api.github.com/repos/VSCodium/VSCodium/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
curl -s https://api.github.com/repos/VSCodium/VSCodium/releases/latest \
  | grep browser_download_url \
  | grep 'armhf.deb"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 curl -L -o codium-$LATEST-armhf.deb || error "Failed to download the codium:armhf"

curl -s https://api.github.com/repos/VSCodium/VSCodium/releases/latest \
  | grep browser_download_url \
  | grep 'arm64.deb"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 curl -L -o codium-$LATEST-arm64.deb || error "Failed to download codium:arm64"

rm $PKGDIR/codium-* || rm $PKGDIR/codium_*

mv codium* $PKGDIR

echo "Updating Goreleaser"
LATEST=`curl -s https://api.github.com/repos/goreleaser/goreleaser/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
curl -s https://api.github.com/repos/goreleaser/goreleaser/releases/latest \
  | grep browser_download_url \
  | grep 'armhf.deb"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 curl -L -o goreleaser-$LATEST-armhf.deb || error "Failed to download goreleaser:armhf"

curl -s https://api.github.com/repos/goreleaser/goreleaser/releases/latest \
  | grep browser_download_url \
  | grep 'arm64.deb"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 curl -L -o goreleaser-$LATEST-arm64.deb || error "Failed to download goreleaser:arm64"

rm $PKGDIR/goreleaser-* || rm $PKGDIR/goreleaser_*

mv goreleaser* $PKGDIR

echo "Updating hyperfine"
LATEST=`curl -s https://api.github.com/repos/sharkdp/hyperfine/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
curl -s https://api.github.com/repos/sharkdp/hyperfine/releases/latest \
  | grep browser_download_url \
  | grep 'armhf.deb"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 curl -L -o hyperfine-$LATEST-armhf.deb || error "Failed to download hyperfine:armhf"

curl -s https://api.github.com/repos/sharkdp/hyperfine/releases/latest \
  | grep browser_download_url \
  | grep 'arm64.deb"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 curl -L -o hyperfine-$LATEST-arm64.deb || error "Failed to download hyperfine:arm64"

rm $PKGDIR/hyperfine-* || rm $PKGDIR/hyperfine_*

mv hyperfine* $PKGDIR

echo "Updating howdy"
LATEST=`curl -s https://api.github.com/repos/boltgolt/howdy/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
curl -s https://api.github.com/repos/boltgolt/howdy/releases/latest \
  | grep browser_download_url \
  | grep '.deb"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 curl -L -o howdy-$LATEST-all.deb || error "Failed to download howdy:all!"

rm $PKGDIR/howdy-* || rm $PKGDIR/howdy_*

mv howdy* $PKGDIR

echo "Updating pacstall"
LATEST=`curl -s https://api.github.com/repos/pacstall/pacstall/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
curl -s https://api.github.com/repos/pacstall/pacstall/releases/latest \
  | grep browser_download_url \
  | grep '.deb"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 curl -L -o pacstall-$LATEST-all.deb || error "Failed to download pacstall:all!"

rm $PKGDIR/pacstall-* || rm $PKGDIR/pacstall_*

mv pacstall* $PKGDIR

echo "Updating croc"
LATEST=`curl -s https://api.github.com/repos/schollz/croc/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
curl -s https://api.github.com/repos/schollz/croc/releases/latest \
  | grep browser_download_url \
  | grep 'ARM.deb"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 curl -L -o croc-$LATEST-armhf.deb || error "Failed to download croc:armhf"

curl -s https://api.github.com/repos/schollz/croc/releases/latest \
  | grep browser_download_url \
  | grep 'ARM64.deb"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 curl -L -o croc-$LATEST-arm64.deb || error "Failed to download croc:arm64"

rm $PKGDIR/croc-* || rm $PKGDIR/croc_*

mv croc* $PKGDIR

cd $PKGDIRA
echo "writing packages..."
EMAIL="$(cat /root/email)"
GPGPASS="$(cat /root/gpgpass)"
rm InRelease Release Release.gpg Packages Packages.gz
dpkg-scanpackages --multiversion . > Packages
gzip -k -f Packages
apt-ftparchive release . > Release
gpg --default-key "${EMAIL}" --batch --pinentry-mode="loopback" --passphrase="$GPGPASS" -abs -o - Release > Release.gpg
gpg --default-key "${EMAIL}" --batch --pinentry-mode="loopback" --passphrase="$GPGPASS" --clearsign -o - Release > InRelease
echo "Repository successfully updated."
