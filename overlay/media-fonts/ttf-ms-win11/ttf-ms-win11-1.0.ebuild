# Copyright 2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A collection of TTF fonts"
HOMEPAGE="http://example.com"
SRC_URI="https://github.com/joeyryan/gentoo-overlay/raw/master/packages/ttf-ms-win11.tar.gz"

LICENSE="all-rights-reserved" # or the appropriate license for your fonts
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND=""

S=${WORKDIR}

src_unpack() {
    default  # This calls the default unpacking function which handles .tar.gz files
}

src_install() {
    dodir /usr/share/fonts/microsoft
    insinto /usr/share/fonts/microsoft
    doins "${WORKDIR}"/*.ttf
}

pkg_postinst() {
    einfo "Updating font cache..."
    fc-cache -f
}
