#!/bin/bash

#Check Root
if [[ $EUID -ne 0 ]]; then
  echo "Need Root to Run! Please try running as Root again."
  exit 1
fi

#set -x
#set +x

#Log File
logfile="setup.log"

#Setup Bash

#Setup Updates for New Server
sudo apt --assume-yes -qq update
sudo apt --assume-yes -qq upgrade
sudo apt --assume-yes -qq autoremove

#Setup user
adduser clovisd -q
adduser cl6web -q 

#Setup permissions
sudo /usr/sbin/visudo | tee -a "$logfile"
​
#Setup SSH Port
sudo nano /etc/ssh/sshd_config | tee -a "$logfile"
#sudo vi /etc/ssh/sshd_config
sudo service sshd restart | tee -a "$logfile"
​
#Setup Hosts
nano /etc/hostname | tee -a "$logfile"
nano /etc/hosts | tee -a "$logfile"
​
#Install Packages
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt --assume-yes -qq update
sudo apt --assume-yes -qq upgrade
sudo apt --assume-yes -qq install apache2 mysql-server python-certbot-apache | tee -a "$logfile"
sudo apt --assume-yes -qq update
sudo mysql_secure_installation --use-default
sudo service apache2 mysql-server restart | tee -a "$logfile"
sudo apt --assume-yes -qq install php libapache2-mod-php php-mcrypt php-mysql | tee -a "$logfile"
sudo apt --assume-yes -qq install php-cli php-curl php-pear php7.2-dev php7.2-zip php7.2-curl php7.2-gd php7.2-mysql php7.2-mcrypt php7.2-xml libapache2-mod-php7.2  | tee -a "$logfile"
sudo service apache2 mysql-server restart | tee -a "$logfile"
sudo apt --assume-yes -qq install mc sl screen htop | tee -a "$logfile"

#SetupPHPAdmin
sudo apt --assume-yes -qq update
sudo apt --assume-yes -qq upgrade
sudo apt --assume-yes -qq autoremove
sudo apt --assume-yes -qq install phpmyadmin php-mbstring php-gettext
​
sudo phpenmod mcrypt
sudo phpenmod mbstring
​
#Setup Directories

#setup universal status files
#setup host directoies
#setup apache conf files

#setup ssl
#setup cron ssl
#sudo certbot renew --dry-run
