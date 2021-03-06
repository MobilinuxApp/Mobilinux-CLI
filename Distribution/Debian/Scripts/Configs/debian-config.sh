#!/bin/bash
### Prepare the system for post-installation
### Things to do:
### 1. Update and Upgrade the system
### 2. Install Necessary Packages
### 3. Configure User Accounts
### 4. Add the user to sudoers file
### 5. Clean up.

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
NOATTR="$(tput sgr0)"

set -e -u

## Add 'contrib non-free' componenets
sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list >/dev/null 2>&1 || true

## Delete Docker Related files as if they're not essential and may cause problems
rm -rf /etc/apt/apt.conf.d/docker-* >/dev/null 2>&1 || true

## Install Packages and Fix segfaults as well
echo "${GREEN}${BOLD}Installing Base Packages....${NOATTR}"
apt update
apt upgrade -y || true
apt install -f -y || true
apt install nano sudo busybox udisks2 dbus-x11 locales pulseaudio procps tzdata dialog wget curl debianutils --no-install-recommends --no-install-suggests -y || true
apt install -f -y || true
dpkg --configure -a || true
apt autoremove -y || true
apt clean || true

## Setup Environment Variables
echo ""
echo "Setting up Environment Variables..."
echo "Adding /sbin path for non-root users"
echo "export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/games:/usr/bin:/usr/sbin:/usr/games:/bin:/sbin" >/etc/profile.d/debian-path.sh
echo "export LANG=C.UTF-8" >/etc/profile.d/debian-lang.sh
echo "export PULSE_SERVER=127.0.0.1" >/etc/profile.d/debian-pulseserver.sh
echo "export MOZ_FAKE_NO_SANDBOX=1" >/etc/profile.d/debian-firefox-fix.sh
echo "export MOZ_DISABLE_GMP_SANDBOX=1" >>/etc/profile.d/debian-firefox-fix.sh
echo "export MOZ_DISABLE_CONTENT_SANDBOX=1" >>/etc/profile.d/debian-firefox-fix.sh
echo "$(cat /.proot.distinfo)" >/etc/debian_chroot

## Configure Packages
echo ""
echo "${GREEN}${BOLD}Configuring Packages....${NOATTR}"
echo "" >/var/lib/dpkg/info/udisks2.postinst
echo "" >/var/lib/dpkg/info/dbus.postinst
dpkg --configure -a
dpkg-reconfigure locales || true
dpkg-reconfigure tzdata || true

## Setup User Accounts
USERNAME="demousername" PASSWORD="demopasswd" DESKTOPENV="desktopenv" SSH_STATUS="demostatus"
echo "${GREEN}${BOLD}Configuring User Accounts....${NOATTR}"
useradd -m -p $PASSWORD -s /bin/bash $USERNAME
echo $USERNAME:$PASSWORD | chpasswd
echo ""
echo "${GREEN}${BOLD}Adding the user to sudoers for sudo access....${NOATTR}"
echo "$USERNAME ALL=(ALL:ALL) NOPASSWD:ALL" >/etc/sudoers.d/$USERNAME
echo "$USERNAME" >/etc/userinfo.rc

install-none() {
  echo "${GREEN}${BOLD}No Desktop Environment will be installed....${NOATTR}"
}

install-xfce4() {
  clear
  echo "${GREEN}${BOLD}Installing XFCE4....${NOATTR}"
  wget --tries=20 --no-check-certificate https://raw.githubusercontent.com/MobilinuxApp/Mobilinux-CLI/master/Distribution/Debian/Scripts/DesktopEnv/XFCE/setup-debian-xfce
  chmod +x setup-debian-xfce
  bash setup-debian-xfce
}

install-lxde() {
  clear
  echo "${GREEN}${BOLD}Installing LXDE....${NOATTR}"
  wget --tries=20 --no-check-certificate https://raw.githubusercontent.com/MobilinuxApp/Mobilinux-CLI/master/Distribution/Debian/Scripts/DesktopEnv/LXDE/setup-debian-lxde
  chmod +x setup-debian-lxde
  bash setup-debian-lxde
}

install-lxqt() {
  clear
  echo "${GREEN}${BOLD}Installing LXQT....${NOATTR}"
  wget --tries=20 --no-check-certificate https://raw.githubusercontent.com/MobilinuxApp/Mobilinux-CLI/master/Distribution/Debian/Scripts/DesktopEnv/LXQT/setup-debian-lxqt
  chmod +x setup-debian-lxqt
  bash setup-debian-lxqt
}

install-mate() {
  clear
  echo "${GREEN}${BOLD}Installing MATE....${NOATTR}"
  wget --tries=20 --no-check-certificate https://raw.githubusercontent.com/MobilinuxApp/Mobilinux-CLI/master/Distribution/Debian/Scripts/DesktopEnv/MATE/setup-debian-mate
  chmod +x setup-debian-mate
  bash setup-debian-mate
}

install-awesome() {
  clear
  echo "${GREEN}${BOLD}Installing Awesome Window Manager....${NOATTR}"
  wget --tries=20 --no-check-certificate https://raw.githubusercontent.com/MobilinuxApp/Mobilinux-CLI/master/Distribution/Debian/Scripts/WindowManager/Awesome/setup-debian-awesome
  chmod +x setup-debian-awesome
  bash setup-debian-awesome
}

install-icewm() {
  clear
  echo "${GREEN}${BOLD}Installing Ice Window Manager....${NOATTR}"
  wget --tries=20 --no-check-certificate https://raw.githubusercontent.com/MobilinuxApp/Mobilinux-CLI/master/Distribution/Debian/Scripts/WindowManager/IceWM/setup-debian-icewm
  chmod +x setup-debian-icewm
  bash setup-debian-icewm
}

install-i3wm() {
  clear
  echo "${GREEN}${BOLD}Installing i3 Window Manager....${NOATTR}"
  wget --tries=20 --no-check-certificate https://raw.githubusercontent.com/MobilinuxApp/Mobilinux-CLI/master/Distribution/Debian/Scripts/WindowManager/i3/setup-debian-i3wm
  chmod +x setup-debian-i3wm
  bash setup-debian-i3wm
}

install-ssh() {
  echo ""
  echo "Installing SSH server...."
  ##sudo apt install openssh-server
  ##wget --tries=20 https://raw.githubusercontent.com/MobilinuxApp/Mobilinux-CLI/master/Distribution/Debian/Scripts/SSH/sshd_config -P /etc/ssh
  echo "Done...."
  echo "You can now start OpenSSH Server by running /etc/init.d/ssh start"
  echo ""
  echo "The Open Server will be started at 127.0.0.1:22"
}

if [ "$DESKTOPENV" == "None" ]; then
  install-none
fi

if [ "$DESKTOPENV" == "XFCE" ]; then
  install-xfce4
fi

if [ "$DESKTOPENV" == "LXDE" ]; then
  install-lxde
fi

if [ "$DESKTOPENV" == "LXQT" ]; then
  install-lxqt
fi

if [ "$DESKTOPENV" == "MATE" ]; then
  install-mate
fi

if [ "$DESKTOPENV" == "AwesomeWM" ]; then
  install-awesome
fi

if [ "$DESKTOPENV" == "ICEWM" ]; then
  install-icewm
fi

if [ "$DESKTOPENV" == "i3WM" ]; then
  install-i3wm
fi

if [ "$SSH_STATUS" == "SSH" ]; then
  install-ssh
else
  echo "SSH will not be installed."
fi
## Check for necessary files to see if installation is successful. will perform sanity checks
ls /etc/userinfo.rc >/dev/null 2>&1
which ps >/dev/null 2>&1
which sudo >/dev/null 2>&1
which busybox >/dev/null 2>&1
which pulseaudio >/dev/null 2>&1
which dbus-launch >/dev/null 2>&1
which nano >/dev/null 2>&1
which dialog >/dev/null 2>&1
