# Maintainer: Kornei Dontsov <KorneiDontsov@gmail.com>

# shellcheck shell=bash
# shellcheck disable=SC2034,SC2164

pkgname=bashme
pkgver=0.1.0
pkgrel=1
pkgdesc="A framework for generating Bash startup scripts"
arch=('any')
url="https://github.com/KorneiDontsov/BashMe"
license=('MIT')
depends=('bash>=5.0')
optdepends=(
    'bash-completion>=2.0: for Tab completions to work in Bash'
    'shfmt>=3.0: for -m/--minify option to work'
)
source=()
sha256sums=()

package() {
    # license
    # shellcheck disable=SC2154
    install -D -m644 "$startdir/LICENSE" "$pkgdir/usr/share/licenses/bashme/LICENSE"

    # bin
    install -d "$pkgdir/usr/bin"
    ln -sr "$pkgdir/usr/share/bashme/bashme" "$pkgdir/usr/bin/bashme"

    # share
    install -D -m755 "$startdir/bashme" "$pkgdir/usr/share/bashme/bashme"
    cp -r "$startdir/lib" "$startdir/std" "$pkgdir/usr/share/bashme/"

    # completion
    install -D -m644 "$startdir/bash_completion.sh" "$pkgdir/usr/share/bash-completion/completions/bashme"
}
