# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

JAVA_PKG_IUSE=""

inherit java-pkg-2 desktop unpacker

DESCRIPTION="Multiplatform transparent client-side encryption of your files in the cloud"
HOMEPAGE="https://cryptomator.org/"
SRC_URI="
    https://github.com/cryptomator/cryptomator/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
    amd64? (
        https://github.com/adoptium/temurin23-binaries/releases/download/jdk-23.0.2%2B7/OpenJDK23U-jdk_x64_linux_hotspot_23.0.2_7.tar.gz -> jdk-23.0.2.tar.gz
        https://download2.gluonhq.com/openjfx/23.0.2/openjfx-23.0.2_linux-x64_bin-jmods.zip -> openjfx-23.0.2.zip
    )
    arm64? (
        https://github.com/adoptium/temurin23-binaries/releases/download/jdk-23.0.2%2B7/OpenJDK23U-jdk_aarch64_linux_hotspot_23.0.2_7.tar.gz -> jdk-23.0.2.tar.gz
        https://download2.gluonhq.com/openjfx/23.0.2/openjfx-23.0.2_linux-aarch64_bin-jmods.zip -> openjfx-23.0.2.zip
    )
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

DEPEND="
    app-arch/unzip
    dev-java/maven
    media-libs/alsa-lib
    sys-fs/fuse:3
    x11-libs/libXrender
    x11-libs/libXtst
    net-libs/libnet
"
RDEPEND="${DEPEND}"

RESTRICT="strip"

S="${WORKDIR}/cryptomator-${PV}"

src_unpack() {
  unpack ${P}.tar.gz
  unpack ./jdk-23.0.2.tar.gz
  unpack openjfx-23.0.2.zip
}

src_prepare() {
  default

  mkdir "${WORKDIR}/jmods"
  unzip -j "${DISTDIR}/openjfx-23.0.2.zip" \
    */javafx.base.jmod \
    */javafx.controls.jmod \
    */javafx.fxml.jmod \
    */javafx.graphics.jmod \
    -d "${WORKDIR}/jmods" || die
}

src_compile() {
  export JAVA_HOME="${WORKDIR}/jdk-23.0.2"
  export JMODS_PATH="${WORKDIR}/jmods:${JAVA_HOME}/jmods"

  cd "${S}" || die

  mvn -B clean package -Djavafx.platform=linux -DskipTests -Plinux || die

  cp LICENSE.txt target
  cp target/cryptomator-*.jar target/mods

  cd target || die

  "${JAVA_HOME}/bin/jlink" \
    --output runtime \
    --module-path "${JMODS_PATH}" \
    --add-modules java.base,java.desktop,java.instrument,java.logging,java.naming,java.net.http,java.scripting,java.sql,java.xml,javafx.base,javafx.graphics,javafx.controls,javafx.fxml,jdk.unsupported,jdk.security.auth,jdk.accessibility,jdk.management.jfr,jdk.net,java.compiler \
    --strip-native-commands \
    --no-header-files \
    --no-man-pages \
    --strip-debug \
    --compress=zip-0 || die

  "${JAVA_HOME}/bin/jpackage" \
    --type app-image \
    --runtime-image runtime \
    --input libs \
    --module-path mods \
    --module org.cryptomator.desktop/org.cryptomator.launcher.Cryptomator \
    --dest . \
    --name cryptomator \
    --vendor "Skymatic GmbH" \
    --java-options '--enable-native-access=org.cryptomator.jfuse.linux.amd64,org.cryptomator.jfuse.linux.aarch64,org.purejava.appindicator' \
    --java-options "-Xss5m" \
    --java-options "-Xmx256m" \
    --java-options "-Dfile.encoding=utf-8" \
    --java-options "-Djava.net.useSystemProxies=true" \
    --java-options "-Dcryptomator.logDir=@{userhome}/.local/share/Cryptomator/logs" \
    --java-options "-Dcryptomator.pluginDir=@{userhome}/.local/share/Cryptomator/plugins" \
    --java-options "-Dcryptomator.settingsPath=@{userhome}/.config/Cryptomator/settings.json:~/.Cryptomator/settings.json" \
    --java-options "-Dcryptomator.p12Path=@{userhome}/.config/Cryptomator/key.p12" \
    --java-options "-Dcryptomator.ipcSocketPath=@{userhome}/.config/Cryptomator/ipc.socket" \
    --java-options "-Dcryptomator.mountPointsDir=@{userhome}/.local/share/Cryptomator/mnt" \
    --java-options "-Dcryptomator.showTrayIcon=true" \
    --java-options "-Dcryptomator.disableUpdateCheck=true" \
    --java-options "-Dcryptomator.buildNumber=gentoo-1" \
    --java-options "-Dcryptomator.appVersion=${PV}" \
    --java-options "-Dcryptomator.integrationsLinux.autoStartCmd=cryptomator" \
    --java-options "-Dcryptomator.networking.truststore.p12Path=/etc/cryptomator/certs.p12" \
    --app-version "${PV}" \
    --verbose || die
}

src_install() {
  dodir /opt
  cp -r target/cryptomator "${D}/opt/cryptomator" || die

  dosym /opt/cryptomator/bin/cryptomator /usr/bin/cryptomator

  domenu dist/linux/common/org.cryptomator.Cryptomator.desktop || die
  insinto /usr/share/mime/packages
  doins dist/linux/common/application-vnd.cryptomator.vault.xml

  insinto /usr/share/icons/hicolor/256x256/apps
  doins dist/linux/common/org.cryptomator.Cryptomator256.png
  insinto /usr/share/icons/hicolor/512x512/apps
  doins dist/linux/common/org.cryptomator.Cryptomator512.png

  for size in scalable symbolic; do
    insinto "/usr/share/icons/hicolor/${size}/apps"
    doins dist/linux/common/org.cryptomator.Cryptomator.tray.svg
    doins dist/linux/common/org.cryptomator.Cryptomator.tray-unlocked.svg
    newins dist/linux/common/org.cryptomator.Cryptomator.tray.svg org.cryptomator.Cryptomator.tray-symbolic.svg
    newins dist/linux/common/org.cryptomator.Cryptomator.tray-unlocked.svg org.cryptomator.Cryptomator.tray-unlocked-symbolic.svg
  done

  dodoc target/LICENSE.txt
}
