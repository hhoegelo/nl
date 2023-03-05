#!/bin/sh

echo "
pkgname=epc-base-meta
pkgver='1.0.0'
pkgrel=1
pkgdesc='Nonlinear Labs Linux for 11i3... NUC systems'
arch=('any')
url="http://nonlinearlabs.de"
license=('MIT')
install=/install.sh
source=(
    'install-nlhook::file:///install/nlhook' 
    'install-oroot::file:///install/oroot' 
    'hook-nlhook::file:///hook/nlhook' 
    'hook-oroot::file:///hook/oroot')
sha256sums=(
    '$(sha256sum /install/nlhook | cut -d " " -f 1 )'
    '$(sha256sum /install/oroot | cut -d " " -f 1 )'
    '$(sha256sum /hook/nlhook | cut -d " " -f 1 )'
    '$(sha256sum /hook/oroot | cut -d " " -f 1 )')
depends=(
    $(cat /package | sed "s/\(.*\)/'\1'/g")
    )

package() {
    mkdir -p \$pkgdir/usr/lib/initcpio/install
    mkdir -p \$pkgdir/usr/lib/initcpio/hooks
    cp \$srcdir/install-nlhook \$pkgdir/usr/lib/initcpio/install/nlhook
    cp \$srcdir/install-oroot \$pkgdir/usr/lib/initcpio/install/oroot
    cp \$srcdir/hook-nlhook \$pkgdir/usr/lib/initcpio/hooks/nlhook
    cp \$srcdir/hook-oroot \$pkgdir/usr/lib/initcpio/hooks/oroot
}"