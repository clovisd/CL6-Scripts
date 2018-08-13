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
apt --assume-yes -qq update
apt --assume-yes -qq upgrade
apt --assume-yes -qq autoremove
echo -e "${LGREEN}== Done == ${NC}"

#Prompt for Server Number
echo -ne "${WHITE}Please enter the S# name scheme: " ; read input
if [[ -z $input ]]; then
    echo "No Value Entered. Exiting."
	exit 1
else
    SERVERNUM=${input}
    echo "Server Name Set to: S${input}.CL6.US (S${SERVERNUM}.CL6WEB.COM)"
fi

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
if [ ! -d /home/root ]; then mkdir /home/root ; fi
cp /home/scripts/setup/.bashrc /home/root/
echo -e "${LGREEN}== Done == ${NC}"

#Setup permissions
echo -e "${BLUE}<== 4. Setup User Permissions ==> ${NC}"
/usr/sbin/visudo
echo -e "${LGREEN}== Done == ${NC}"

#Setup SSH Port
echo -e "${BLUE}<== 5. Setup SSH Settings ==> ${NC}"
echo -e "${YELLOW} Setting settings ${NC}"
nano /etc/ssh/sshd_config
#vi /etc/ssh/sshd_config
echo -e "${YELLOW} Restarting SSH Service ${NC}"
service sshd restart
echo -e "${LGREEN}== Done == ${NC}"

#Setup Hosts
echo -e "${BLUE}<== 6. Set Server Name & Hosts ==> ${NC}"
echo -e "${YELLOW} Set Hostname ${NC}"
nano /etc/hostname
echo -e "${YELLOW} Set Hosts ${NC}"
nano /etc/hosts
echo -e "${LGREEN}== Done == ${NC}"

#Install Packages
echo -e "${BLUE}<== 7. Install Apps & Packages ==> ${NC}"
echo -e "${YELLOW} Setting up CertBot Repo ${NC}"
add-apt-repository -y ppa:certbot/certbot
echo -e "${YELLOW} Installing Apache / SQL / CertBot ${NC}"
apt --assume-yes -qq install apache2 mysql-server python-certbot-apache | tee -a "$logfile"
apt --assume-yes -qq update
apt --assume-yes -qq upgrade
echo -e "${YELLOW} Setup SQL Security ${NC}"
mysql_secure_installation --use-default
echo -e "${YELLOW} Restarting Apache/MySQL ${NC}"
service mysql-server restart | tee -a "$logfile"
service apache2 restart | tee -a "$logfile"
echo -e "${YELLOW} Installing PHP Packages ${NC}"
apt --assume-yes -qq install hp php7.2-mysql php7.2-curl php7.2-xml php7.2-zip  php7.2-gd php7.2-common php7.2-json php7.2-opcache php7.2-readline php7.2-dev php7.2-mbstring php-pear | tee -a "$logfile"
echo -e "${YELLOW} Restarting Apache/MySQL ${NC}"
service mysql-server restart | tee -a "$logfile"
service apache2 restart | tee -a "$logfile"
echo -e "${YELLOW} Installing Personal Packages ${NC}"
apt --assume-yes -qq install mc sl screen htop | tee -a "$logfile"
echo -e "${LGREEN}== Done == ${NC}"

#SetupPHPAdmin
echo -e "${BLUE}<== 8. PHPMyAdmin ==> ${NC}"
apt --assume-yes -qq update
apt --assume-yes -qq upgrade
apt --assume-yes -qq autoremove
echo -e "${YELLOW} Installing PHPMyAdmin ${NC}"
apt --assume-yes -qq install phpmyadmin
echo -e "${LGREEN}== Done == ${NC}"

#Setup Host Directories
if [ ! -d /home/cl6web ]; then mkdir /home/cl6web ; fi
if [ ! -d /home/cl6web/s${SERVERNUM}.cl6.us ]; then mkdir /home/cl6web/s${SERVERNUM}.cl6.us ; fi
if [ ! -d /home/cl6web/example.com ]; then mkdir /home/cl6web/example.com ; fi
if [ ! -d /home/cl6web/example.com/logs ]; then mkdir /home/cl6web/example.com/logs ; fi
if [ ! -d /home/cl6web/example.com/html ]; then mkdir /home/cl6web/example.com/html ; fi
if [ ! -d /home/cl6web/example.com/backup ]; then mkdir /home/cl6web/example.com/backup ; fi
if [ ! -d /home/cl6web/example.com/automation ]; then mkdir /home/cl6web/example.com/automation ; fi

#Setup CL6 Greeter Page
if [ ! -d /home/scripts/setup/greeter ]; then mkdir /home/scripts/setup/greeter ; fi
cp /home/scripts/setup/greeter.tar.gz /home/scripts/setup/greeter
cd /home/scripts/setup/
tar -zxvf /home/scripts/setup/greeter.tar.gz
if [ ! -d /home/cl6web/s${SERVERNUM}.cl6.us/greeting ]; then mkdir /home/cl6web/s${SERVERNUM}.cl6.us/greeting ; fi
cp -R /home/scripts/setup/status/ /home/cl6web/s${SERVERNUM}.cl6.us/greeter
nano /etc/apache2/sites-available/util.cl6.us.conf

#Setup Server Status
if [ ! -d /home/scripts/setup/status ]; then mkdir /home/scripts/setup/status ; fi
cp /home/scripts/setup/status.tar.gz /home/scripts/setup/status
cd /home/scripts/setup/
tar -zxvf /home/scripts/setup/status.tar.gz /home/scripts/setup/status
if [ ! -d /home/cl6web/s${SERVERNUM}.cl6.us/status ]; then mkdir /home/cl6web/s${SERVERNUM}.cl6.us/status ; fi
cp -R /home/scripts/setup/status/ /home/cl6web/s${SERVERNUM}.cl6.us/status
nano /etc/apache2/sites-available/s${SERVERNUM}.cl6.us.conf

#CRON SSL Renew