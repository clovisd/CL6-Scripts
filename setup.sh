#!/bin/bash
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/opt/cl6/logs/setup_exec.log 2>&1
#set -x
#set +x

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

#Color Codes
RED='\033[0;31m' #Error
YELLOW='\033[1;33m' #Doing Something
GREEN='\033[0;32m' #Auto Something
BLUE='\033[1;34m' #Headline
LGREEN='\033[1;32m' #Completed
NC='\033[0m'
WHITE='\033[1;37m'

OS=$(</opt/cl6/info/os.info)
VER=$(</opt/cl6/info/ver.info)
SETUPV=$(</opt/cl6/info/setupv.info)
LOADERV=$(</opt/cl6/info/loaderv.info)

echo -e "OS: ${OS}"
echo -e "VER: ${VER}"

echo -e "${GREEN}<== CL6 Server Setup Script ==>"
echo -e "${LGREEN} ${SETUPV} - clovisd"
echo -ne "${RED}Press Enter when ready!${NC}" ; read -r input

#Log File
logfile="/opt/cl6/logs/setup.log"

#Check Root
if [[ $EUID -ne 0 ]]; then
  echo "Need Root to Run! Please try running as Root again."
  exit 1
fi

#Prompt for Server Info
if [[ -f /opt/cl6/info/servernum.info ]]; then
	SERVERNUM=$(</opt/cl6/info/servernum.info)
	echo "Server Name Set to: S${SERVERNUM}.CL6.US (S${SERVERNUM}.CL6WEB.COM)"
else
	echo -ne "${WHITE}Please enter the S# name scheme: " ; read -r SERVERNUM
	if [[ -z $SERVERNUM ]]; then
		echo "No Value Entered. Exiting.${NC}"
		exit 1
	else
		echo "${SERVERNUM}" > /opt/cl6/info/servernum.info
		echo "Server Name Set to: S${SERVERNUM}.CL6.US (S${SERVERNUM}.CL6WEB.COM)"
	fi
fi

#FigureOut IP
SERVERIP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
echo "Server IP is: ${SERVERIP}"
echo "${SERVERIP}" > /opt/cl6/info/serverip.info

systemRemove () {

	echo -e "${BLUE}│ ┌${RED}[${YELLOW}${FUNCNAME[0]}${RED}] - ${GREEN}Removing $1 ${NC}"
	(apt-get remove -qq $1) >> ${logfile} & PID=$! 2>&1
		printf  "${BLUE}│ │${GREEN} REMOVE:"
	while kill -0 $PID 2> /dev/null; do 
		printf  "▄"
		sleep 3
	done
	printf "${GREEN}${NC} - Done\n"
	echo -e "${BLUE}│ └${GREEN} Done Removing $1 ${NC}"

}

systemInstall () {

	echo -e "${BLUE}├─┬${RED}[${YELLOW}${FUNCNAME[0]}${RED}] - ${GREEN}Installing $1 ${NC}"
	(apt-get install -qq $1) >> ${logfile} & PID=$! 2>&1
		printf  "${BLUE}│ │${GREEN} INSTALL:"
	while kill -0 $PID 2> /dev/null; do 
		printf  "▄"
		sleep 3
	done
	printf "${GREEN}${NC} - Done\n"
	echo -e "${BLUE}│ └${GREEN} Done installing $1 ${NC}"

}

systemUpdate () {

	echo -e "${BLUE}├─┬${RED}[${YELLOW}${FUNCNAME[0]}${RED}] - ${GREEN}Updating ${NC}"
	(apt-get update) >> ${logfile} & PID=$! 2>&1
		printf  "${BLUE}│ │${GREEN} UPDATE:"
	while kill -0 $PID 2> /dev/null; do 
		printf  "▄"
		sleep 3
	done
	printf "${GREEN}${NC} - Done\n"
	echo -e "${BLUE}│ └${GREEN} Done Updating ${NC}"

}

systemUpgrade () {

	echo -e "${BLUE}├─┬${RED}[${YELLOW}${FUNCNAME[0]}${RED}] - ${GREEN}Upgrading ${NC}"
	(DEBIAN_FRONTEND=readline apt-get upgrade -y) >> ${logfile} & PID=$! 2>&1
		printf  "${BLUE}│ │${GREEN} UPGRADE:"
	while kill -0 $PID 2> /dev/null; do 
		printf  "▄"
		sleep 3
	done
	printf "${GREEN}${NC} - Done\n"
	echo -e "${BLUE}│ └${GREEN} Done Upgrading ${NC}"

}

systemAutoClean () {

	echo -e "${BLUE}├─┬${RED}[${YELLOW}${FUNCNAME[0]}${RED}] - ${GREEN}AutoClean ${NC}"
	(apt-get autoclean -qq) >> ${logfile} & PID=$! 2>&1
		printf  "${BLUE}│ │${GREEN} AUTOCLEAN:"
	while kill -0 $PID 2> /dev/null; do 
		printf  "▄"
		sleep 3
	done
	printf "${GREEN}${NC} - Done\n"
	echo -e "${BLUE}│ └${GREEN} Done AutoClean ${NC}"

}

systemAutoRemove () {

	echo -e "${BLUE}├─┬${RED}[${YELLOW}${FUNCNAME[0]}${RED}] - ${GREEN}AutoRemove ${NC}"
	(apt-get autoremove -qq) >> ${logfile} & PID=$! 2>&1
		printf  "${BLUE}│ │${GREEN} AUTOREMOVE:"
	while kill -0 $PID 2> /dev/null; do 
		printf  "▄"
		sleep 3
	done
	printf "${GREEN}${NC} - Done\n"
	echo -e "${BLUE}│ └${GREEN} Done AutoRemove ${NC}"
	
}

systemServiceRestart () {

	echo -e "${BLUE}├─┬${RED}[${YELLOW}${FUNCNAME[0]}${RED}] - ${GREEN}Restarting Service $1 ${NC}"
	service "$1" restart >> ${logfile} 2>&1
	echo -e "${BLUE}│ └${GREEN} Done Restarting $1 ${NC}"
}

systemServiceStop () {

	echo -e "${BLUE}├─┬${RED}[${YELLOW}${FUNCNAME[0]}${RED}] - ${GREEN}Stopping Service $1 ${NC}"
	service "$1" stop >> ${logfile} 2>&1
	echo -e "${BLUE}│ └${GREEN} Done Stopping $1 ${NC}"

}

systemServiceStart () {

	echo -e "${BLUE}├─┬${RED}[${YELLOW}${FUNCNAME[0]}${RED}] - ${GREEN}Starting Service $1 ${NC}"
	service "$1" start >> ${logfile} 2>&1cd 
	echo -e "${BLUE}│ └${GREEN} Done Starting $1 ${NC}"

}

basicSetupUtility () {

	#Setup Updates for New Server
	echo -e "${WHITE} >> ${BLUE}[basicSetupUtility] ${GREEN}Running Updates, Upgrade, and AutoRemove. ${NC}"
		
	systemUpdate
	systemUpgrade
	systemAutoRemove
	systemAutoClean
	
	setupHostDirectories

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

basicShutdownUtility () {

	#Setup Updates for New Server
	echo -e "${WHITE} >> ${BLUE}[basicShutdownUtility] ${GREEN}Running Updates, Upgrade, and AutoRemove. ${NC}"
		
	systemUpdate
	systemUpgrade
	systemAutoRemove
	systemAutoClean

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

setupHostDirectories () {

	#Setup Host Directories
	echo -e "${WHITE} >> ${BLUE}[setupHostDirectories] ${GREEN}Setup CL6 OPT Directory. ${NC}"
	
	if [ ! -d /opt/cl6/hosting/ ]; then mkdir /opt/cl6/hosting/ ; fi
	if [ ! -d /opt/cl6/hosting/s"${SERVERNUM}".cl6.us ]; then mkdir /opt/cl6/hosting/s"${SERVERNUM}".cl6.us ; fi
	if [ ! -d /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/logs ]; then mkdir /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/logs ; fi
	if [ ! -d /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html ]; then mkdir /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html ; fi
	if [ ! -d /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/backup ]; then mkdir /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/backup ; fi
	if [ ! -d /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/automation ]; then mkdir /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/automation ; fi
	if [ ! -d /opt/cl6/hosting/example.com ]; then mkdir /opt/cl6/hosting/example.com ; fi
	if [ ! -d /opt/cl6/hosting/example.com/logs ]; then mkdir /opt/cl6/hosting/example.com/logs ; fi
	if [ ! -d /opt/cl6/hosting/example.com/html ]; then mkdir /opt/cl6/hosting/example.com/html ; fi
	if [ ! -d /opt/cl6/hosting/example.com/backup ]; then mkdir /opt/cl6/hosting/example.com/backup ; fi
	if [ ! -d /opt/cl6/hosting/example.com/automation ]; then mkdir /opt/cl6/hosting/example.com/automation ; fi

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

setupUsers () {

	echo -e "${WHITE} >> ${BLUE}[userManager] ${GREEN}Creating Users and Setting Directories"

	echo -ne "\n${RED}>> clovisd account info:${NC}\n"
	read -r -s -p "Enter Password: " CLPASSWD
	
	if [[ -z $CLPASSWD ]]; then
		echo "No Value Entered. Exiting.${NC}"
		exit 1
	else
		echo "clovisd:$CLPASSWD" > /opt/cl6/vault/clovisd-string.vault
		echo "$CLPASSWD" > /opt/cl6/vault/clovisd-passwd.vault
	fi
	
	echo -ne "\n${RED}>> Cl6Web account info:${NC}\n"
	read -r -s -p "Enter Password: " C6PASSWD
	
	if [[ -z $C6PASSWD ]]; then
		echo "No Value Entered. Using clovisd password.${NC}"
		echo "cl6web:$CLPASSWD" > /opt/cl6/vault/cl6-string.vault
		echo "$CLPASSWD" > /opt/cl6/vault/cl6-passwd.vault
		C6PASSWD=$CLPASSWD
	else
		echo "cl6web:$C6PASSWD" > /opt/cl6/vault/cl6-string.vault
		echo "$C6PASSWD" > /opt/cl6/vault/cl6-passwd.vault
	fi

	#echo -ne "\n${RED}>> Root account info:${NC}\n"
	#read -r -s -p "Enter Password: " ROOTPASSWD
	#if [[ -z $ROOTPASSWD ]]; then
	#    echo "No Value Entered. Exiting.${NC}"
	#	exit 1
	#else

	ROOTPASSWD=$C6PASSWD
	
	echo "root:$ROOTPASSWD" > /opt/cl6/vault/root-string.vault
	echo "$ROOTPASSWD" > /opt/cl6/vault/root-passwd.vault

	#Setup user
	echo -e "${BLUE}<== 2. Users & Passwords ==> ${NC}"

	if [ ! -d /home/cl6web ]; then mkdir /home/cl6web ; fi
	if [ ! -d /home/root ]; then mkdir /home/root ; fi

	echo -e "${YELLOW} Setup User: clovisd ${NC}"
	useradd clovisd -m -s /bin/bash
	chpasswd<<<"clovisd:${CLPASSWD}"
	echo -e "${YELLOW} Setup User: cl6web ${NC}"
	useradd cl6web -G www-data -s /bin/bash
	chpasswd<<<"cl6web:${C6PASSWD}"
	
	echo -e "${YELLOW} Setup User: root ${NC}"
	sudo passwd -dl root
	#echo "${ROOTPASSWD}" | passwd --stdin root

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

cloudflareInfo () {

	#Save and Configure CloudFlare Info
	echo -e "${WHITE} >> ${BLUE}[cloudflareInfo] ${GREEN}Collecting API and Email Info. ${NC}"

	echo -ne "\n${RED}>> Cloudflare Account Info:${NC}\n"
	if [[ -f /opt/cl6/vault/cfemail.vault ]]; then
		CFEMAIL=$(</opt/cl6/vault/cfemail.vault)
		echo "CF Email Set to: ${CFEMAIL}"
	else
		read -r -p "Enter CloudFlare Email: " CFEMAIL
		if [[ -z $CFEMAIL ]]; then
			echo "No Value Entered. Using default."
			echo "clovisdelmotte@gmail.com" > /opt/cl6/vault/cfemail.vault
			CFEMAIL="clovisdelmotte@gmail.com"
		else
			echo "$CFEMAIL" > /opt/cl6/vault/cfemail.vault
		fi
	fi
	if [[ -f /opt/cl6/vault/cfkey.vault ]]; then
		CFK=$(</opt/cl6/vault/cfkey.vault)
		echo "CF Auth Key Set to: ${CFK}"
	else
		read -r -p "Enter CloudFlare Auth Key: " CFK
		if [[ -z $CFK ]]; then
			echo "No Value Entered. Exiting.${NC}"
			exit 1
		else
			echo "$CFK" > /opt/cl6/vault/cfkey.vault
		fi
	fi

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"
}

uptimerobotInfo () {

	#Save and Configure UptimeRobot Info
	echo -e "${WHITE} >> ${BLUE}[uptimerobotInfo] ${GREEN}Collecting API Info. ${NC}"

	echo -ne "\n${RED}>> UptimeRobot Info:${NC}\n"
	if [[ -f /opt/cl6/vault/uptimekey.vault ]]; then
		UPTIMEKEY=$(</opt/cl6/vault/uptimekey.vault)
		echo "UptimeRobot Key Set to: ${UPTIMEKEY}"
	else
		read -r -p "Enter API Key: " UPTIMEKEY
		if [[ -z $UPTIMEKEY ]]; then
			echo "No Value Entered. Exiting.${NC}"
			exit 1
		else
			echo "$UPTIMEKEY" > /opt/cl6/vault/uptimekey.vault
		fi
	fi

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"
}

installConfigureAPACHE () {
	echo -e "${RED}!!!!!!!!!! NEW UI TEST START !!!!!!!!!!${NC}"
	echo -e "\n===\n===\n==="

	#Setup Apache
	echo -e "${BLUE}┌${RED}[${YELLOW}${FUNCNAME[0]}${RED}] - ${LGREEN}Running Apache Setup and Install. ${NC}"

	systemUpdate
	echo -e "${BLUE}├─${LGREEN} Installing Apache. ${NC}"
	systemInstall "apache2"
	# (apt-get install -qq apache2) >> ${logfile} & PID=$! 2>&1
		# printf  "${GREEN}[INSTALL:\n"
	# while kill -0 $PID 2> /dev/null; do 
		# printf  "."
		# sleep 3
	# done
	# printf "${GREEN}]${NC} - Done\n"

	echo -e "${BLUE}├─${LGREEN} Cleaning Up Apache Directories. ${NC}"
	cd /var/ && rm -R www
	cd /etc/apache2/sites-enabled/ && rm -R ./*
	cd /etc/apache2/sites-available/ && rm -R ./*
	
	systemServiceRestart "apache2"

	echo -e "${BLUE}├─${LGREEN} Setting up HTPASSWD Files. ${NC}"
	htpasswd -c -b /opt/cl6/vault/.htpasswd clovisd "${CLPASSWD}" >> ${logfile} 2>&1
	htpasswd -b /opt/cl6/vault/.htpasswd cl6web "${C6PASSWD}" >> ${logfile} 2>&1

	echo -e "${BLUE}└─${LGREEN} Done ${NC}"

	echo -e "\n===\n===\n==="	
	echo -e "${RED}!!!!!!!!!! NEW UI TEST END !!!!!!!!!!${NC}"
	
}

installConfigureMYSQL () {

	#Installing, Setting Up, & Securing MySQL Server
	echo -e "${WHITE} >> ${BLUE}[installConfigureMYSQL] ${GREEN}Installing, Setting Up, & Securing MySQL Server. ${NC}"

	echo "mysql-server mysql-server/root_password password $ROOTPASSWD" | debconf-set-selections >> ${logfile} 2>&1
	echo "mysql-server mysql-server/root_password_again password $ROOTPASSWD" | debconf-set-selections >> ${logfile} 2>&1
	#debconf-get-selections | grep mysql-server >> ${logfile} 2>&1

	systemUpdate
	systemInstall "mysql-server"

	# (apt-get install -qq mysql-server) >> ${logfile} & PID=$! 2>&1
		# printf  "${GREEN}[INSTALL:\n"
	# while kill -0 $PID 2> /dev/null; do 
		# printf  "."
		# sleep 3
	# done
	# printf "${GREEN}]${NC} - Done\n"

	echo -e "${YELLOW} Setup SQL Security ${NC}"
	mysql_secure_installation --use-default --password="${ROOTPASSWD}" >> ${logfile} 2>&1

	systemServiceRestart "mysql"
	
	echo -e "${YELLOW}Configure MySQL ${NC}"
	
	mysql -u root -p"${ROOTPASSWD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'clovisd'@'localhost' IDENTIFIED BY '${CLPASSWD}';" >> ${logfile} 2>&1
	mysql -u root -p"${ROOTPASSWD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'cl6web'@'localhost' IDENTIFIED BY '${C6PASSWD}';" >> ${logfile} 2>&1
	mysql -u root -p"${ROOTPASSWD}" -e "FLUSH PRIVILEGES;" >> ${logfile} 2>&1
	
	#mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${ROOTPASSWD}';"
	#mysql -u root -p"${ROOTPASSWD}" -e "FLUSH PRIVILEGES;"
	#mysql -u root -p"${ROOTPASSWD}" -e "CREATE USER ‘clovisd’@’%’ IDENTIFIED BY ‘${CLPASSWD}’;"
	#mysql -u root -p"${ROOTPASSWD}" -e "CREATE USER cl6@’%’ IDENTIFIED BY ‘${C6PASSWD}’;"
	#mysql -u root -p"${ROOTPASSWD}" -e "GRANT ALL PRIVILEGES ON *.* TO ‘clovisd’@’%’;"
	#mysql -u root -p"${ROOTPASSWD}" -e "GRANT ALL PRIVILEGES ON *.* TO ‘cl6web’@’%’;"
	
	echo -e "${LGREEN} == Done == ${NC}"
	
	systemServiceRestart "mysql"
	systemServiceRestart "apache2"
	
	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

installConfigurePHP () {

	#Installing & Setting Up PHP + Modules
	echo -e "${WHITE} >> ${BLUE}[installConfigurePHP] ${GREEN}Installing & Setting Up PHP and its Modules. ${NC}"
	
	echo -e "${YELLOW} Setting up PHP Repo ${NC}"
	add-apt-repository -y ppa:ondrej/php >> ${logfile} 2>&1
	
	echo -e "${YELLOW} Installing PHP Packages ${NC}"
	
	systemUpdate
	systemInstall "php7.2 php7.2-mysql php7.2-curl php7.2-xml php7.2-zip php7.2-gd php7.2-common php7.2-json php7.2-opcache php7.2-readline php7.2-dev php7.2-gmp php7.2-mbstring php7.2-soap php7.2-xmlrpc php7.2-imap"
	#systemInstall "php7.3 php7.3-mysql php7.3-curl php7.3-xml php7.3-zip php7.3-gd php7.3-common php7.3-json php7.3-opcache php7.3-readline php7.3-dev php7.3-gmp php7.3-mbstring php7.3-soap php7.3-xmlrpc php7.3-imap"
	#PHP Base Packages
	# (apt-get install -qq php7.2 php7.2-mysql php7.2-curl php7.2-xml php7.2-zip php7.2-gd php7.2-common php7.2-json php7.2-opcache php7.2-readline php7.2-dev php7.2-gmp php7.2-mbstring php7.2-soap php7.2-xmlrpc php7.2-imap) >> ${logfile} & PID=$! 2>&1
	#php-pear
		# printf  "${GREEN}[INSTALL 1:\n"
	# while kill -0 $PID 2> /dev/null; do 
		# printf  "."
		# sleep 3
	# done
	# printf "${GREEN}]${NC} - Done\n"
	
	#PHP Secondary Packages
	
	systemInstall "libmcrypt-dev libapache2-mod-security2"
	
	systemInstall "pkg-config php-pear"
	
	#gcc make autoconf libc-dev 
	
	systemUpdate
	# (apt-get install -qq libmcrypt-dev) >> ${logfile} & PID=$! 2>&1
	#php-pecl
		# printf  "${GREEN}[INSTALL 2:\n"
	# while kill -0 $PID 2> /dev/null; do 
		# printf  "."
		# sleep 3
	# done
	# printf "${GREEN}]${NC} - Done\n"
	#install --nodeps mcrypt-snapshot
	#PHP 3rd Party Packages

	#(pecl -q install mcrypt-snapshot) >> ${logfile} & PID=$! 2>&1
	(pecl -q install mcrypt-1.0.1) >> ${logfile} & PID=$! 2>&1
		printf  "${GREEN}[INSTALL:\n"
	while kill -0 $PID 2> /dev/null; do 
		printf  "."
		sleep 3
	done
	printf "${GREEN}]${NC} - Done\n"
	
	echo -e "${YELLOW} Setting Up mcrypt ${NC}"
	
	echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/mods-available/mcrypt.ini
	ln -s /etc/php/7.2/mods-available/mcrypt.ini /etc/php/7.2/cli/conf.d/20-mcrypt.ini
	ln -s /etc/php/7.2/mods-available/mcrypt.ini /etc/php/7.2/apache2/conf.d/20-mcrypt.ini
	
	#echo extension=/usr/lib/php/20180731/mcrypt.so > /etc/php/7.3/mods-available/mcrypt.ini
	##ln -s /etc/php/7.3/mods-available/mcrypt.ini /etc/php/7.3/apache2/conf.d/20-mcrypt.ini
	
	#Setup PHP
	echo -e "${BLUE}<== 3. Setup PHP ==> ${NC}"
	echo -e "${YELLOW} Copying Content to PHP.INI ${NC}"
	cp /opt/cl6/setup/extract/php.ini /etc/php/7.2/apache2/php.ini
	cp /opt/cl6/setup/extract/php.ini /etc/php/7.2/cli/php.ini
	
	#cp /opt/cl6/setup/extract/php.ini /etc/php/7.3/apache2/php.ini
	#cp /opt/cl6/setup/extract/php.ini /etc/php/7.3/cli/php.ini
	
	systemServiceRestart "mysql"
	systemServiceRestart "apache2"

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

installConfigurePHPMYADMIN() {

	#Installing, Setting Up, & Securing PHPMyAdmin
	echo -e "${WHITE} >> ${BLUE}[installConfigurePHPMYADMIN] ${GREEN}Installing, Setting Up, & Securing PHPMYAdmin. ${NC}"

	echo -e "${YELLOW} Setting up PHPMyAdmin Repo ${NC}"
	add-apt-repository -y ppa:nijel/phpmyadmin >> ${logfile} 2>&1
	
	systemUpdate

	echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections >> ${logfile} 2>&1
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections >> ${logfile} 2>&1
	echo "phpmyadmin phpmyadmin/app-password-confirm password $ROOTPASSWD" | debconf-set-selections >> ${logfile} 2>&1
	echo "phpmyadmin phpmyadmin/mysql/admin-pass password $ROOTPASSWD" | debconf-set-selections >> ${logfile} 2>&1
	echo "phpmyadmin phpmyadmin/mysql/app-pass password $ROOTPASSWD" | debconf-set-selections >> ${logfile} 2>&1
	#debconf-get-selections | grep phpmyadmin >> ${logfile} 2>&1

	#SetupPHPAdmin
	echo -e "${BLUE}<== 8. PHPMyAdmin ==> ${NC}"
	echo -e "${YELLOW} Installing PHPMyAdmin ${NC}"
	
	systemInstall "phpmyadmin"
	# (DEBIAN_FRONTEND=noninteractive apt-get install -qq phpmyadmin) >> ${logfile} & PID=$! 2>&1
		# printf  "${GREEN}[INSTALL:\n"
	# while kill -0 $PID 2> /dev/null; do 
		# printf  "."
		# sleep 3
	# done
	# printf "${GREEN}]${NC} - Done\n"
	
	echo -e "${YELLOW}Setting Auth File ${NC}"

	cp /opt/cl6/setup/extract/.htaccess /usr/share/phpmyadmin
	cp /opt/cl6/setup/extract/phpmyadmin.conf /etc/apache2/conf-available/

	#echo -e "${YELLOW} Set ${GREEN}AllowOverride All${YELLOW} for PHPMYAdmin ${NC}"
	#echo -ne "${WHITE}Press Enter when read -ry!" ; read -r input
	#mysql -u root -p"Q~NE!p9#PnC2m6Su" < /usr/share/doc/phpmyadmin/examples/create_tables.sql
	
	echo -e "${YELLOW} Enable Plugins ${NC}"
	phpenmod mbstring
	phpenmod mcrypt
	
	systemServiceRestart "mysql"
	systemServiceRestart "apache2"
	
	echo -e "${WHITE} << ${GREEN} Done! ${NC}"
	
}

installConfigureCERTBOT () {

	#Installing & Setting Up Certbot
	echo -e "${WHITE} >> ${BLUE}[installConfigureCERTBOT] ${GREEN}Installing & Setting Up Cerbot. ${NC}"

	echo -e "${YELLOW} Setting up CertBot Repo ${NC}"

	add-apt-repository -y ppa:certbot/certbot >> ${logfile} 2>&1
	systemUpdate

	# (apt-get install -qq python-certbot-apache) >> ${logfile} & PID=$! 2>&1
		# printf  "${GREEN}[INSTALL:\n"
	# while kill -0 $PID 2> /dev/null; do 
		# printf  "."
		# sleep 3
	# done
	# printf "${GREEN}]${NC} - Done\n"

	systemUpdate
	systemInstall "python-certbot-apache"

	#CRON SSL Renew
	crontab="0 0 1 * * certbot renew  >/dev/null 2>&1"
	crontab2="0 0 1 * * certbot renew  >/dev/null 2>&1"
	#crontab -e root
	crontab -u root -l; echo "$crontab" | crontab -u root - >> ${logfile} 2>&1
	crontab -u clovisd -l; echo "$crontab2" | crontab -u clovisd - >> ${logfile} 2>&1
	
	systemServiceRestart "mysql"
	systemServiceRestart "apache2"

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

installPageSpeed () {

	#Installing & Setting Up PageSpeed Module
	echo -e "${WHITE} >> ${BLUE}[installPageSpeed] ${GREEN}Installing & Setting Up PageSpeed. ${NC}"

	cd /opt/cl6/setup || return
	
	wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

	wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-beta_current_amd64.deb
	dpkg -i mod-pagespeed-beta_current_amd64.deb 

	apt-get -f install
	
	systemServiceRestart "apache2"

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

certbotCreateCert () {

	#Creating Cerbot Cert
	echo -e "${WHITE} >> ${BLUE}[certbotCreateCert] ${GREEN}Setting up a new Cert. ${NC}"

	echo -e "${YELLOW} Generating CertBot Certs ${NC}"
	certbot run -m ssl@cl6web.com --agree-tos --no-eff-email --redirect -a webroot -i apache -w /opt/cl6/hosting/$1/html -d $1 -d $2 >> ${logfile} 2>&1

	#certbot --apache-n -d s${SERVERNUM}.cl6.us -d s${SERVERNUM}.cl6web.com
	#certbot certonly -m ssl@cl6web.com --agree-tos --no-eff-email --redirect --webroot -w /home/cl6web/s${SERVERNUM}.cl6.us/status -d s${SERVERNUM}.cl6.us -d s${SERVERNUM}.cl6web.com

	systemServiceRestart "apache2"

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"
	
	}

installPersonalPackages () {

	#Setup QOL Packages
	echo -e "${WHITE} >> ${BLUE}[installPersonalPackages] ${GREEN}Setting up Personal / QOL Packages. ${NC}"

	echo -e "${YELLOW} Installing Other QOL Packages ${NC}"
	
	systemUpdate
	systemInstall "mc sl screen htop fish"
	
	# (apt-get install -qq mc sl screen htop fish) >> ${logfile} & PID=$! 2>&1
		# printf  "${GREEN}[INSTALL:\n"
	# while kill -0 $PID 2> /dev/null; do 
		# printf  "."
		# sleep 3
	# done
	# printf "${GREEN}]${NC} - Done\n"

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

setupBashFiles () {

	#Setting up Bashrc files for users
	echo -e "${WHITE} >> ${BLUE}[setupBashFiles] ${GREEN}Setting up Bash Files. ${NC}"

	echo -e "${BLUE}<== 3. Setup Bash ==> ${NC}"
	echo -e "${YELLOW} Setting Up Bash for All Users ${NC}"
	cp /opt/cl6/setup/.bashrc /home/clovisd/
	cp /opt/cl6/setup/.bashrc /home/cl6web
	cp /opt/cl6/setup/.bashrc /home/root/
	echo -e "${LGREEN} == Done == ${NC}"

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

setupSudoUsers () {

	#Creating Cerbot Cert
	echo -e "${WHITE} >> ${BLUE}[setupSudoUsers] ${GREEN}Setting up Sudo Permissions. ${NC}"

	#Setup permissions
	echo -e "${BLUE}<== 4. Setup User Permissions ==> ${NC}"
	
	SUDO="clovisd    ALL=(ALL:ALL) NOPASSWD:ALL
	cl6web    ALL=(ALL:ALL) ALL
	"

	echo "${SUDO}" > /etc/sudoers.d/cl6
	echo -e "${LGREEN} == Done == ${NC}"
	
	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

setupSSHD () {

	#Creating Cerbot Cert
	echo -e "${WHITE} >> ${BLUE}[setupSSHD] ${GREEN}Setting up SSHD Security. ${NC}"

	#Setup SSH Port
	echo -e "${BLUE}<== 5. Setup SSH Settings ==> ${NC}"
	echo -e "${YELLOW} Setting SSHD settings ${NC}"

	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

	cp /opt/cl6/setup/extract/sshd_config /etc/ssh

	echo -e "${YELLOW} Restarting SSH Service ${NC}"
	echo "d /run/sshd 0755 root root" > /usr/lib/tmpfiles.d/sshd.conf
	
	systemServiceRestart "sshd"
	
	echo -e "${LGREEN} == Done == ${NC}"
	
	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

setupHosts () {

	#Setting up Server Hosts File
	echo -e "${WHITE} >> ${BLUE}[setupHosts] ${GREEN}Setting up Hosts File. ${NC}"

	#Setup Hosts
	echo -e "${BLUE}<== 6. Set Server Name & Hosts ==> ${NC}"
	echo -e "${GREEN} Set Hostname ${NC}"

	HOSTNAME="S${SERVERNUM}"

	echo "${HOSTNAME}" > /etc/hostname
	#nano /etc/hostname
	
	echo -e "${GREEN} Set Hosts ${NC}"

	HOSTS="# Basic Hosts
127.0.0.1 localhost.localdomain localhost
# Auto-generated hostname. Please do not remove this comment.

${SERVERIP} S${SERVERNUM}.CL6.US S${SERVERNUM}
127.0.1.1 CL6-${SERVERNUM}.localdomain CL6-${SERVERNUM}
127.0.1.1 S${SERVERNUM}.CL6.US CL6-${SERVERNUM}
127.0.0.1 localhost

# IPv6 Hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts

# Net Hosts
​${SERVERIP} S${SERVERNUM}.CL6.US
​${SERVERIP} S${SERVERNUM}.CL6WEB.COM"

	echo "${HOSTS}" > /etc/hosts
	
	#nano /etc/hosts
	echo -e "${LGREEN} == Done == ${NC}"
	
	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

setupSwapDisk () {

	cp /etc/sysctl.conf /etc/sysctl.conf.bak
	cp /etc/fstab /etc/fstab.bak
	
	fallocate -l 2G /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
	cp /opt/cl6/setup/extract/sysctl.conf /etc/sysctl.conf
	
}

setupOpenVPN () {
	echo "Pineapple"
}

setupTweekPacks () {
	echo "Pineapple"
}


cloudflareCreateA () {

	#Setting up Server Hosts File
	echo -e "${WHITE} >> ${BLUE}[cloudflareCreateA] ${GREEN}Creating A Record for Domain $1 and address $2. ${NC}"

	echo -e "${YELLOW} Creating A Records w/ CloudFlare ${NC}"

	ZONE=$1
	DNSRECORD=$2

	ZONEID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE&status=active" \
	-H "X-Auth-Email: $CFEMAIL" \
	-H "X-Auth-Key: $CFK" \
	-H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

	curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records" \
	-H "X-Auth-Email: $CFEMAIL" \
	-H "X-Auth-Key: $CFK" \
	-H "Content-Type: application/json" \
	--data '{"type":"A","name":"'"$DNSRECORD"'","content":"'"$SERVERIP"'","proxied":false}' >> ${logfile} 2>&1

	echo -e "${LGREEN} == Done == ${NC}"
	
	sleep 3s
	
	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

uptimerobotCreateMonitor () {

	#Setting up Server Hosts File
	echo -e "${WHITE} >> ${BLUE}[uptimerobotCreateMonitor] ${GREEN}Creating Uptime Record for URL $1 with name $2. ${NC}"

	#Uptime Robot
	echo -e "${BLUE}<== 13. Uptime Robot ==> ${NC}"
	curl -X POST \
		-H "Cache-Control: no-cache" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		-d 'api_key='"$UPTIMEKEY"'&format=json&type=4&sub_type=1&url='"$1"'&friendly_name='"$2"'' "https://api.uptimerobot.com/v2/newMonitor" >> ${logfile} 2>&1
	
	printf "\n"
	
	# curl -X POST \
		# -H "Cache-Control: no-cache" \
		# -H "Content-Type: application/x-www-form-urlencoded" \
		# -d 'api_key='$UPTIMEKEY'&format=json&type=4&sub_type=2&url=https://s'${SERVERNUM}'.cl6.us&friendly_name=S'${SERVERNUM}' (HTTPS)&http_username=cl6web&http_password='$C6PASSWD'' "https://api.uptimerobot.com/v2/newMonitor" >> ${logfile} 2>&1
	
	echo -e "${LGREEN} == Done == ${NC}"
	#sudo rm -R /home/scripts/setup
	
	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

websiteCatchAll () {

	#Setting up Catch-All
	echo -e "${WHITE} >> ${BLUE}[websiteCatchAll] ${GREEN}Setting up Catch All. ${NC}"

	#Setup Catch-All
	echo -e "${BLUE}<== 11. Setup Catch-All Page ==> ${NC}"
	if [ ! -d /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html/catch-all ]; then mkdir /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html/catch-all ; fi

	echo -e "${YELLOW} Moving Archive ${NC}"
	cp /opt/cl6/setup/catch-all.tar.gz /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html/catch-all
	cd /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html/catch-all || return

	echo -e "${YELLOW} Extracting Archive ${NC}"
	tar -zxvf catch-all.tar.gz  >> ${logfile} 2>&1
	rm catch-all.tar.gz

	echo -e "${YELLOW} Creating Apache Conf ${NC}"

#CATCHALL="<VirtualHost _default_:80>
#	ServerName catch.cl6.us
#	ServerAlias *.cl6.us
#	ServerAlias *.cl6web.com
#	ServerAlias www.*.cl6web.com
#	ServerAlias www.*.cl6.us

#	ServerAdmin webmaster@cl6.us
#	DocumentRoot /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/catch-all
	
#	ErrorLog /opt/cl6/hosting/s${SERVERNUM}.cl6.us/logs/catch.log
#	CustomLog /opt/cl6/hosting/s${SERVERNUM}.cl6.us/logs/catch-custom.log combined

#	<Directory /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/catch-all>
#		AllowOverride All
#		Require all granted
#	</Directory>
#</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet"

#echo "${CATCHALL}" > /etc/apache2/sites-available/catch.cl6.us.conf
#cd /etc/apache2/sites-enabled && ln -s /etc/apache2/sites-available/catch.cl6.us.conf

	echo -e "${YELLOW} Creating SymLink ${NC}"
	echo -e "${YELLOW} Restarting Apache ${NC}"
	
	systemServiceRestart "apache2"
	
	echo -e "${LGREEN} == Done == ${NC}"

}

websiteStatusPage () {

	#Setting up Catch-All
	echo -e "${WHITE} >> ${BLUE}[websiteStatusPage] ${GREEN}Setting up Status Page. ${NC}"

	#Setup Server Status
	echo -e "${BLUE}<== 12. Setup Status Page ==> ${NC}"
	echo -e "${YELLOW} Moving Archive ${NC}"
	cp /opt/cl6/setup/status-page.tar /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html
	cd /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html
	echo -e "${YELLOW} Extracting Archive ${NC}"
	tar -xvf status-page.tar  >> ${logfile} 2>&1
	cd status-page
	cp -R * /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html
	rm -R /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html/status-page
	rm /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html/status-page.tar >> ${logfile} 2>&1
	chown -R www-data:www-data /opt/cl6/hosting/

	echo -e "${YELLOW} Setting HTACCESS File ${NC}"
	cp /opt/cl6/setup/extract/.htaccess /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html/status/

	echo -e "${YELLOW} Setting up Downloads Dir ${NC}"
	mkdir /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/dl
	cp /opt/cl6/setup/index/.htaccess /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/dl
	cp -R /opt/cl6/setup/index /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/dl/

	echo -e "${YELLOW} Creating Apache Conf ${NC}"

	STATUSPAGE="<VirtualHost *:80>
	ServerName s${SERVERNUM}.cl6.us
	ServerAlias s${SERVERNUM}.cl6web.com
	ServerAlias www.s${SERVERNUM}.cl6web.com
	ServerAlias www.s${SERVERNUM}.cl6.us

	ServerAdmin webmaster@cl6.us
	DocumentRoot /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html

	ErrorLog /opt/cl6/hosting/s${SERVERNUM}.cl6.us/logs/status-page.log
	CustomLog /opt/cl6/hosting/s${SERVERNUM}.cl6.us/logs/status-page-custom.log combined

	<Directory /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html>
		AllowOverride All
		Require all granted
	</Directory>
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet"
	echo "${STATUSPAGE}" > /etc/apache2/sites-available/s"${SERVERNUM}".cl6.us.conf

	echo -e "${YELLOW} Creating SymLink ${NC}"
	cd /etc/apache2/sites-enabled && ln -s /etc/apache2/sites-available/s"${SERVERNUM}".cl6.us.conf

	systemServiceRestart "apache2"

	cloudflareCreateA "cl6.us" "s${SERVERNUM}.cl6.us"
	cloudflareCreateA "cl6web.com" "s${SERVERNUM}.cl6web.com"

	systemServiceRestart "apache2"
	
	uptimerobotCreateMonitor "http://s${SERVERNUM}.cl6.us" "S${SERVERNUM} (HTTP)"
	uptimerobotCreateMonitor "https://s${SERVERNUM}.cl6.us" "S${SERVERNUM} (HTTPS)"

	sleep 3s

	systemServiceRestart "apache2"

	sleep 3s

	certbotCreateCert "s${SERVERNUM}.cl6.us" "s${SERVERNUM}.cl6web.com"

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"
	
}

setupCleanUp () {

	#Cleaning up and Setting Security Settings
	echo -e "${WHITE} >> ${BLUE}[setupCleanUp] ${GREEN}Cleaning and Securing Directorys. ${NC}"

	#CleanUp
	rm /opt/cl6/vault/clovisd-passwd.vault
	rm /opt/cl6/vault/clovisd-string.vault
	
	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

discordWebhook () {

	#Discord Ping
	echo -e "${WHITE} >> ${BLUE}[discordPhoneHome] ${GREEN}Discord Phone Home Webhook ${NC}"

	echo -e "${YELLOW} Discord Ping ${NC}"
	cd /opt/cl6/setup && ./discord.sh
	
	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

}

setupReboot () {

	echo -ne "${WHITE}Press Enter when Reboot ready!${NC}" ; read -r input
	reboot && exit
	#shutdown -t

	echo -e "${WHITE} << ${GREEN} Done! ${NC}"

exit
}

#Select Server Install Setup to Run
echo -e "Please select Install Type:"

#Setup Base Programs
PS3='Select Install Type: '
options=("Test Sequence" "Full" "DigitalOcean" "GoogleCloud" "SparkVPS" "Setup VPN" "Add Subdomain" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "Full")
            echo -e "${RED} >> RUNNING FULL INSTALL! ${NC}"
			CURRENTINSTALL="$OPT"
			echo -e "${RED} >> Selected $OPT or ${OPT}!"
			echo -e "${RED} >> Selected $CURRENTINSTALL or ${CURRENTINSTALL}!"
			
			setupUsers
			cloudflareInfo
			uptimerobotInfo
			basicSetupUtility
			
			setupBashFiles
			setupSudoUsers
			setupSSHD
			setupHosts
			setupSwapDisk
			
			installConfigureAPACHE
			installConfigureMYSQL
			installConfigurePHP
			installConfigurePHPMYADMIN
			installConfigureCERTBOT
			installPageSpeed
			
			installPersonalPackages
			
			websiteStatusPage
			setupCleanUp
			discordWebhook
			basicShutdownUtility
			setupReboot
            ;;
        "DigitalOcean")
            echo -e "${RED} >> RUNNING DIGITAL OCEAN INSTALL! ${NC}"
			CURRENTINSTALL="$OPT"
			echo -e "${RED} >> Selected $OPT or ${OPT}!"
			echo -e "${RED} >> Selected $CURRENTINSTALL or ${CURRENTINSTALL}!"
			
			setupUsers
			cloudflareInfo
			uptimerobotInfo
			basicSetupUtility
			
			setupBashFiles
			setupSudoUsers
			setupSSHD
			setupHosts
			setupSwapDisk
			
			installConfigureAPACHE
			installConfigureMYSQL
			installConfigurePHP
			installConfigurePHPMYADMIN
			installConfigureCERTBOT
			installPageSpeed
			
			installPersonalPackages
			
			websiteStatusPage
			setupCleanUp
			discordWebhook
			basicShutdownUtility
			setupReboot
            ;;
        "GoogleCloud")
            echo -e "${RED} >> RUNNING GCD INSTALL! ${NC}"
			CURRENTINSTALL="$OPT"
			echo -e "${RED} >> Selected $OPT or ${OPT}!"
			echo -e "${RED} >> Selected $CURRENTINSTALL or ${CURRENTINSTALL}!"
			
			setupUsers
			cloudflareInfo
			uptimerobotInfo
			basicSetupUtility
			
			setupBashFiles
			#setupSudoUsers
			#setupSSHD
			setupHosts
			setupSwapDisk
			
			installConfigureAPACHE
			installConfigureMYSQL
			installConfigurePHP
			installConfigurePHPMYADMIN
			installConfigureCERTBOT
			installPageSpeed
			
			installPersonalPackages
			
			websiteStatusPage
			setupCleanUp
			discordWebhook
			basicShutdownUtility
			setupReboot
            ;;
        "SparkVPS")
            echo -e "${RED} >> RUNNING SPARKVPS INSTALL! ${NC}"
			CURRENTINSTALL="$OPT"
			echo -e "${RED} >> Selected $OPT or ${OPT}!"
			echo -e "${RED} >> Selected $CURRENTINSTALL or ${CURRENTINSTALL}!"
			
			setupUsers
			cloudflareInfo
			uptimerobotInfo
			basicSetupUtility
			
			setupBashFiles
			setupSudoUsers
			setupSSHD
			#setupSwapDisk
			#setupHosts
			
			installConfigureAPACHE
			installConfigureMYSQL
			installConfigurePHP
			installConfigurePHPMYADMIN
			installConfigureCERTBOT
			installPageSpeed
			
			installPersonalPackages
			
			websiteStatusPage
			setupCleanUp
			discordWebhook
			basicShutdownUtility
			setupReboot
            ;;
        "Setup VPN")
            echo -e "${RED} >> RUNNING VPN Setup! ${NC}"
			cd /opt/cl6/setup || return
			chmod a+x openvpn.sh
			./openvpn.sh
            ;;
        "Add Subdomain")
            echo -e "${RED} >> Adding Single Domain + SSL! ${NC}"
			logfile="/opt/cl6/logs/domainadd.log"
			echo -e "Log File: ${logfile}"
			echo -ne "${WHITE}Certbot Sequence Pause!${NC}" ; read -r input
			
			echo -ne "${WHITE}Please Enter Directory Domain: " ; read -r certDomain
			if [[ -z $certDomain ]]; then
				echo "No Value Entered. Exiting.${NC}"
				exit 1
			else
				echo "Directory Set To: /opt/cl6/hosting/$certDomain/html/"
			fi
			
			echo -ne "${WHITE}Please Enter Direct Directory Domain: " ; read -r certRecord
			if [[ -z $certRecord ]]; then
				echo "No Value Entered. Exiting.${NC}"
				exit 1
			else
				echo "Using Domains $certRecord & www.$certRecord for cert."
				certD1="$certRecord"
				certD2="www.$certRecord"
			fi
			
			echo -ne "${WHITE}Certbot Sequence Pause!${NC}" ; read -r input
			echo "Variables: $certRecord $certDomain $certD1 $certD2"
			echo -ne "${WHITE}Certbot Sequence Pause!${NC}" ; read -r input
			
			certbot run -m ssl@cl6web.com --agree-tos --no-eff-email --redirect -a webroot -i apache -w /opt/cl6/hosting/$certDomain/html -d $certD1 -d $certD2

			
			echo -ne "${WHITE}Certbot Sequence Pause!${NC}" ; read -r input
			setupReboot
            break
            ;;
        "Test Sequence")
            echo -e "${RED} >> STARTING TASKS! ${NC}"
			logfile="/opt/cl6/logs/testsequence.log"
			echo -e "Log File: ${logfile}"
			echo -ne "${WHITE}Test Sequence Pause!${NC}" ; read -r input
			
			echo -ne "${WHITE}Test Sequence Pause!${NC}" ; read -r input
			setupReboot
            break
            ;;
        "Exit")
            break
            ;;
        *) echo invalid option;;
    esac
done

echo "This shouldn't happen! Exiting! - Code Null"

exit 420