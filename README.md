# Astral Vault

Here is a collection of packages I use on Gentoo that are not in the main repository. Free for anyone to use and modify for their own purposes.

- ttf-ms-win11 - Fonts from Windows 11.
- otpclient - Best OTP client I have used.
- dell-bios-fan-control - Simple C program to enable fan control on Dell laptops.
- plasma-applet-thermal-monitor - KDE Plasma applet to show temperature information.
- feather - Lightweight Monero desktop wallet with Trezor integration.

Create the following file at /etc/portage/repos.conf/astral-vault.conf

```
[astral-vault]
location = /usr/local/portage/astral-vault
sync-type = git
sync-uri = https://github.com/joeyryan/gentoo-overlay.git
sync-depth = 1
sync-subdirectory = overlay
```
