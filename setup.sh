#!/bin/bash

#set -x
#set +x

#Color Codes
RED='\033[0;31m' #Error
YELLOW='\033[1;33m' #Doing Something
GREEN='\033[0;32m' #Auto Something
BLUE='\033[1;34m' #Headline
LGREEN='\033[1;32m' #Completed
NC='\033[0m'
WHITE='\033[1;37m'

#Log File
logfile="/home/scripts/logs/setup.log"

#Check Root
if [[ $EUID -ne 0 ]]; then
  echo "Need Root to Run! Please try running as Root again."
  exit 1
fi


#Setup Updates for New Server
echo -e "${BLUE}<== 1. Updates & Upgrades ==> ${NC}"
sudo apt --assume-yes -qq update >> ${logfile} 2>&1
sudo apt --assume-yes -qq upgrade >> ${logfile} 2>&1
sudo apt --assume-yes -qq autoremove >> ${logfile} 2>&1
echo -e "${LGREEN}== Done == ${NC}"

#Setup user
echo -e "${BLUE}<== 2. Users & Passwords ==> ${NC}"
echo -e "${YELLOW} Setup User: clovisd ${NC}"
adduser clovisd -q
echo -e "${YELLOW} Setup User: cl6web ${NC}"
adduser cl6web -q 
echo -e "${LGREEN}== Done == ${NC}"

#Setup Bash
echo -e "${BLUE}<== 3. Setup Bash ==> ${NC}"
echo -e "${YELLOW} Setting Up Bash for All Users ${NC}"
cp /home/scripts/setup/.bashrc /home/clovisd/
cp /home/scripts/setup/.bashrc /home/cl6web/
cp /home/scripts/setup/.bashrc /home/root/
echo -e "${LGREEN}== Done == ${NC}"

#Setup permissions
echo -e "${BLUE}<== 4. Setup User Permissions ==> ${NC}"
sudo /usr/sbin/visudo
echo -e "${LGREEN}== Done == ${NC}"
​
#Setup SSH Port
echo -e "${BLUE}<== 5. Setup SSH Settings ==> ${NC}"
echo -e "${YELLOW} Setting settings ${NC}"
sudo nano /etc/ssh/sshd_config
#sudo vi /etc/ssh/sshd_config
echo -e "${YELLOW} Restarting SSH Service ${NC}"
sudo service sshd restart
echo -e "${LGREEN}== Done == ${NC}"
​
#Setup Hosts
echo -e "${BLUE}<== 6. Set Server Name & Hosts ==> ${NC}"
echo -e "${YELLOW} Set Hostname ${NC}"
nano /etc/hostname
echo -e "${YELLOW} Set Hosts ${NC}"
nano /etc/hosts
echo -e "${LGREEN}== Done == ${NC}"
​
#Install Packages
echo -e "${BLUE}<== 7. Install Apps & Packages ==> ${NC}"
echo -e "${YELLOW} Setting up CertBot Repo ${NC}"
sudo add-apt-repository -y ppa:certbot/certbot
echo -e "${YELLOW} Installing Apache / SQL / CertBot ${NC}"
sudo apt --assume-yes -qq install apache2 mysql-server python-certbot-apache | tee -a "$logfile"
sudo apt --assume-yes -qq update >> ${logfile} 2>&1
sudo apt --assume-yes -qq upgrade >> ${logfile} 2>&1
echo -e "${YELLOW} Setup SQL Security ${NC}"
sudo mysql_secure_installation --use-default
echo -e "${YELLOW} Restarting Apache/MySQL ${NC}"
sudo service apache2 mysql-server restart | tee -a "$logfile"
echo -e "${YELLOW} Installing PHP Packages ${NC}"
sudo apt --assume-yes -qq install hp php7.2-mysql php7.2-curl php7.2-xml php7.2-zip  php7.2-gd php7.2-common php7.2-json php7.2-opcache php7.2-readline php7.2-dev php7.2-mbstring php-pear | tee -a "$logfile"
echo -e "${YELLOW} Restarting Apache/MySQL ${NC}"
sudo service apache2 mysql-server restart | tee -a "$logfile"
echo -e "${YELLOW} Installing Personal Packages ${NC}"
sudo apt --assume-yes -qq install mc sl screen htop | tee -a "$logfile"
echo -e "${LGREEN}== Done == ${NC}"

#SetupPHPAdmin
echo -e "${BLUE}<== 8. PHPMyAdmin ==> ${NC}"
sudo apt --assume-yes -qq update >> ${logfile} 2>&1
sudo apt --assume-yes -qq upgrade >> ${logfile} 2>&1
sudo apt --assume-yes -qq autoremove >> ${logfile} 2>&1
echo -e "${YELLOW} Installing PHPMyAdmin ${NC}"
sudo apt --assume-yes -qq install phpmyadmin
echo -e "${LGREEN}== Done == ${NC}"

#setup universal status files
#setup host directoies
#setup apache conf files

#setup ssl
#setup cron ssl
#sudo certbot renew --dry-run
