#!/bin/bash
# built for CloudatCost Ubuntu Servers 
# Late 2018 needs further testing

if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root" 
       exit 1
else
#start installs Webmin user and CaC password https://ip-address:10000
#Nextcloud via snap https://ip-address admin and CAC password 
#lbzip2 for better parallel compression and Zswap, 
#duplicity for backup, lynx browser 
#Subsonic media server http://ip-address:4040
#OpenVPN server must transfer file to computer or cellphone

# Webmin install port 10000
cd ~
echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee -a /etc/apt/sources.list
echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib"  | sudo tee -a /etc/apt/sources.list
wget http://www.webmin.com/jcameron-key.asc
sudo apt-key add jcameron-key.asc
apt update
#install included below with all others

# Installs a list of applications and files some essential 
# Look for what to add or remove
apt install webmin htop python3 lbzip2 build-essential nmap git curl bind9 dnsmasq duplicity gnupg ncftp
 unzip cifs-utils nfs-common moreutils checkinstall screen software-properties-common open-vm-tools
 lynx openjdk-8-jre -y

# Install Sonic media server http to 4040
wget https://s3-eu-west-1.amazonaws.com/subsonic-public/download/subsonic-6.1.5.deb
dpkg -i subsonic-6.1.5.deb
systemctl restart subsonic
mkdir /var/music

# Install Nextcloud using snap just us server ip-address but user and cac password
snap install nextcloud

# Enable zswap in etc/default/grub but makes a backup first
cp /etc/default/grub /etc/default/grub.bak 
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="zswap.enabled=1 zswap.compressor=lz4"/g' /etc/default/grub
update-grub
echo lz4 >> /etc/initramfs-tools/modules
echo lz4_compress >> /etc/initramfs-tools/modules
update-initramfs -u

# runs road warrior Openvpn install script file in root folder reboot once this finishes
# Test and verify reboot seems to break Openvpn might not need zswap or mod 

wget https://git.io/vpn -O openvpn-install.sh
time bash openvpn-install.sh
echo ""
echo "after OpenVPN finishes do a reboot to activate zswap is enabled"
echo ""
echo "check zswap using cat /sys/module/zswap/parameters/enabled"
fi

