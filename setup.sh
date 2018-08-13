#!/bin/bash

#Check Root
if [[ $EUID -ne 0 ]]; then
  echo "Need Root to Run! Please try running as Root again."
  exit 1
fi

#set -x
#set +x

#Color Codes
RED='\033[0;31m'
LG='\033[0m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
LGREEN='\033[1;32m'
WHITE='\033[1;37m'
LG='\033[0;37m'

#Log File
logfile="setup.log"

#Setup Updates for New Server
echo -e "${BLUE} Updates & Upgrades"
sudo apt --assume-yes -qq update >> ${logfile} 2>&1
sudo apt --assume-yes -qq upgrade >> ${logfile} 2>&1
sudo apt --assume-yes -qq autoremove >> ${logfile} 2>&1

#Setup user
echo -e "${GREEN} Setup User: clovisd"
adduser clovisd -q
echo -e "${GREEN} Setup User: cl6web"
adduser cl6web -q 

#Setup Bash
echo -e "${LGREEN} Setting Up Bash for All Users"
cp /home/scripts/setup/.bashrc /home/clovisd/
cp /home/scripts/setup/.bashrc /home/cl6web/
cp /home/scripts/setup/.bashrc /home/root/

#Setup permissions
echo -e "${GREEN} Setup Sudo Permissions"
sudo /usr/sbin/visudo
​
#Setup SSH Port
echo -e "${GREEN} Setup SSH Settings"
sudo nano /etc/ssh/sshd_config
#sudo vi /etc/ssh/sshd_config
echo -e "${YELLOW} Restarting SSHD Service"
sudo service sshd restart
​
#Setup Hosts
nano /etc/hostname
nano /etc/hosts
​
#Install Packages
echo -e "${BLUE} Setting up CertBot Repo"
sudo add-apt-repository -y ppa:certbot/certbot
echo -e "${BLUE} Installing Apache / SQL / CertBot"
sudo apt --assume-yes -qq install apache2 mysql-server python-certbot-apache | tee -a "$logfile"
sudo apt --assume-yes -qq update >> ${logfile} 2>&1
sudo apt --assume-yes -qq upgrade >> ${logfile} 2>&1
sudo mysql_secure_installation --use-default
echo -e "${YELLOW} Restarting Apache/MySQL"
sudo service apache2 mysql-server restart | tee -a "$logfile"
echo -e "${BLUE} Installing PHP Packages"
sudo apt --assume-yes -qq install hp php7.2-mysql php7.2-curl php7.2-xml php7.2-zip  php7.2-gd php7.2-common php7.2-json php7.2-opcache php7.2-readline php7.2-dev php7.2-mbstring php-pear | tee -a "$logfile"
echo -e "${YELLOW} Restarting Apache/MySQL"
sudo service apache2 mysql-server restart | tee -a "$logfile"
echo -e "${BLUE} Installing Personal Packages"
sudo apt --assume-yes -qq install mc sl screen htop | tee -a "$logfile"

#SetupPHPAdmin
echo -e "${BLUE} Updates & Upgrades"
sudo apt --assume-yes -qq update >> ${logfile} 2>&1
sudo apt --assume-yes -qq upgrade >> ${logfile} 2>&1
sudo apt --assume-yes -qq autoremove >> ${logfile} 2>&1
echo -e "${BLUE} Installing PHPMyAdmin"
sudo apt --assume-yes -qq install phpmyadmin

#setup universal status files
#setup host directoies
#setup apache conf files

#setup ssl
#setup cron ssl
#sudo certbot renew --dry-run
