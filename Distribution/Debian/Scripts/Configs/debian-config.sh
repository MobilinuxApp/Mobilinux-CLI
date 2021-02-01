#!/bin/bash
### Prepare the system for post-installation
### Things to do:
### 1. Update and Upgrade the system
### 2. Install Necessary Packages
### 3. Configure User Accounts
### 4. Add the user to sudoers file
### 5. Clean up.
set -e -u

## Add 'contrib non-free' componenets
sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list >/dev/null 2>&1 || true

## Delete Docker Related files as if they're not essential and may cause problems
rm -rf /etc/apt/apt.conf.d/docker-* >/dev/null 2>&1 || true

## Install Packages and Fix segfaults as well
apt update
apt upgrade -y || true
apt install -f -y || true
apt install nano sudo busybox udisks2 dbus-x11 locales pulseaudio procps tzdata dialog --no-install-recommends --no-install-suggests -y || true
apt install -f -y || true
dpkg --configure -a || true
apt autoremove -y || true
apt clean || true

## Setup Environment Variables
echo ""
echo "Setting up Environment Variables..."
echo "Adding /sbin path for non-root users"
echo "export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/games:/usr/bin:/usr/sbin:/usr/games:/bin:/sbin" > /etc/profile.d/debian-path.sh
echo "export LANG=C.UTF-8" > /etc/profile.d/debian-lang.sh
echo "export PULSE_SERVER=127.0.0.1" > /etc/profile.d/debian-pulseserver.sh
echo "export MOZ_FAKE_NO_SANDBOX=1" > /etc/profile.d/debian-firefox-fix.sh
echo "$(cat /.proot.distinfo)" > /etc/debian_chroot

## Configure Packages
echo ""
echo "Configuring Packages... "
echo "" > /var/lib/dpkg/info/udisks2.postinst
echo "" > /var/lib/dpkg/info/dbus.postinst
dpkg --configure -a
dpkg-reconfigure locales || true
dpkg-reconfigure tzdata || true

## Setup User Accounts
USERNAME="demousername" PASSWORD="demouserpasswd"
echo "Configuring User Accounts.... "
##read -p "Enter your UNIX username (lower case): " username
##useradd -s /bin/bash -m $USERNAME
useradd -m -p $PASSWORD -s /bin/bash $USERNAME
echo $USERNAME:$PASSWORD | chpasswd
echo "Adding the user to sudoers for sudo access"
echo "$USERNAME ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
echo "$USERNAME" > /etc/userinfo.rc

## Check for necessary files to see if installation is successful. will perform sanity checks
ls /etc/userinfo.rc >/dev/null 2>&1
which ps >/dev/null 2>&1
which sudo >/dev/null 2>&1
which busybox >/dev/null 2>&1
which pulseaudio >/dev/null 2>&1
which dbus-launch >/dev/null 2>&1
which nano >/dev/null 2>&1
which dialog >/dev/null 2>&1
