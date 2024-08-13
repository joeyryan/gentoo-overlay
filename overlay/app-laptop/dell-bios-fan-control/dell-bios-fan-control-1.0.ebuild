# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Utility to control BIOS fan control on some Dell laptops"
HOMEPAGE="https://github.com/TomFreudenberg/dell-bios-fan-control"

# Use commit of specific version
GIT_COMMIT="27006106595bccd6c309da4d1499f93d38903f9a"
SRC_URI="https://github.com/TomFreudenberg/dell-bios-fan-control/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${GIT_COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
	dobin dell-bios-fan-control
	dodoc README.md
}
