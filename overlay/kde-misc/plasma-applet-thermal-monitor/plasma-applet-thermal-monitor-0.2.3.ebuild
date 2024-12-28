# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit ecm kde.org optfeature
VERSION="0.2.3"

DESCRIPTION="Plasma 6 applet for monitoring CPU, GPU and other available temperature sensors"
HOMEPAGE="https://store.kde.org/p/998915/
    https://gitlab.com/agurenko/plasma-applet-thermal-monitor"

SRC_URI="https://invent.kde.org/olib/thermalmonitor/-/archive/v${VERSION}/thermalmonitor-v${VERSION}.tar.bz2"
KEYWORDS="amd64 ~amd64"

LICENSE="MIT"
SLOT="6"

# Set the source directory manually
S="${WORKDIR}/thermalmonitor-v${VERSION}"

# Add dependencies
DEPEND="
    >=kde-plasma/ksystemstats-6.1.3
    >=kde-plasma/libksysguard-6.1.3
    >=kde-frameworks/kitemmodels-6.4.0
    >=kde-frameworks/kdeclarative-6.4.0
"

RDEPEND="${DEPEND}"

pkg_postinst() {
    ecm_pkg_postinst
#    optfeature "monitor temperature of NVMe drives" sys-apps/nvme-cli
}
