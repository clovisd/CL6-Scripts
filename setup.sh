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
V=$(</opt/cl6/info/cl6v.info)

echo -e "OS: ${OS}"
echo -e "VER: ${VER}"

echo -e "${GREEN}<== CL6 Server Setup Script ==>"
echo -e "${LGREEN} ${V} - clovisd"
echo -ne "${RED}Press Enter when ready!${NC}" ; read input

#Log File
logfile="/opt/cl6/logs/setup.log"

#Check Root
if [[ $EUID -ne 0 ]]; then
  echo "Need Root to Run! Please try running as Root again."
  exit 1
fi

#Prompt for Server Info
echo -ne "${WHITE}Please enter the S# name scheme: " ; read SERVERNUM
if [[ -z $SERVERNUM ]]; then
    echo "No Value Entered. Exiting.${NC}"
	exit 1
else
	echo "${SERVERNUM}" > /opt/cl6/info/servernum.info
    echo "Server Name Set to: S${input}.CL6.US (S${SERVERNUM}.CL6WEB.COM)"
fi
echo -ne "\n${RED}>> clovisd account info:${NC}\n"
read -s -p "Enter Password: " CLPASSWD
if [[ -z $CLPASSWD ]]; then
    echo "No Value Entered. Exiting.${NC}"
	exit 1
else
    echo "clovisd:$CLPASSWD" > /opt/cl6/vault/clovisd-string.vault
    echo "$CLPASSWD" > /opt/cl6/vault/clovisd-passwd.vault
fi
echo -ne "\n${RED}>> Cl6Web account info:${NC}\n"
read -s -p "Enter Password: " C6PASSWD
if [[ -z $C6PASSWD ]]; then
    echo "No Value Entered. Exiting.${NC}"
	exit 1
else
    echo "cl6web:$C6PASSWD" > /opt/cl6/vault/cl6web-string.vault
    echo "$C6PASSWD" > /opt/cl6/vault/cl6web-passwd.vault
fi
echo -ne "\n${RED}>> Root account info:${NC}\n"
read -s -p "Enter Password: " ROOTPASSWD
if [[ -z $ROOTPASSWD ]]; then
    echo "No Value Entered. Exiting.${NC}"
	exit 1
else
    echo "root:$ROOTPASSWD" > /opt/cl6/vault/root-string.vault
    echo "$ROOTPASSWD" > /opt/cl6/vault/root-passwd.vault
fi
echo -ne "\n${RED}>> Cloudflare Account Info:${NC}\n"
read -p "Enter CloudFlare Email: " CFEMAIL
if [[ -z $CFEMAIL ]]; then
    echo "No Value Entered. Using default."
	echo "clovisdelmotte@gmail.com" > /opt/cl6/vault/cfemail.vault
else
    echo "$CFEMAIL" > /opt/cl6/vault/cfemail.vault
fi
echo -ne "\n"
read -p "Enter CloudFlare Auth Key: " CFK
if [[ -z $CFK ]]; then
    echo "No Value Entered. Exiting.${NC}"
	exit 1
else
    echo "$CFK" > /opt/cl6/vault/cfkey.vault
fi
echo ""
#SetupConf
echo "mysql-server mysql-server/root_password password $ROOTPASSWD" | debconf-set-selections >> ${logfile} 2>&1
echo "mysql-server mysql-server/root_password_again password $ROOTPASSWD" | debconf-set-selections >> ${logfile} 2>&1
echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections >> ${logfile} 2>&1
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections >> ${logfile} 2>&1
echo "phpmyadmin phpmyadmin/app-password-confirm password $ROOTPASSWD" | debconf-set-selections >> ${logfile} 2>&1
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $ROOTPASSWD" | debconf-set-selections >> ${logfile} 2>&1
echo "phpmyadmin phpmyadmin/mysql/app-pass password $ROOTPASSWD" | debconf-set-selections >> ${logfile} 2>&1
debconf-get-selections|grep phpmyadmin >> ${logfile} 2>&1
debconf-get-selections|grep mysql-server >> ${logfile} 2>&1
#FigureOut IP
SERVERIP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
echo "Server IP is: ${SERVERIP}"
echo "${SERVERIP}" > /opt/cl6/info/serverip.info

#Setup Updates for New Server
echo -e "${BLUE}<== 1. Updates & Upgrades ==> ${NC}"
(apt-get update) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPDATE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
(DEBIAN_FRONTEND=readline apt-get upgrade -y) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPGRADE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
DEBIAN_FRONTEND=noninteractive
(apt-get autoremove -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[AUTOREMOVE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
echo -e "${LGREEN} == Done == ${NC}"

#Install Packages
echo -e "${BLUE}<== 7. Install Apps & Packages ==> ${NC}"
echo -e "${YELLOW} Setting up CertBot Repo ${NC}"
add-apt-repository -y ppa:certbot/certbot >> ${logfile} 2>&1
echo -e "${YELLOW} Setting up PHP Repo ${NC}"
add-apt-repository -y ppa:ondrej/php >> ${logfile} 2>&1
echo -e "${YELLOW} Setting up PHPMyAdmin Repo ${NC}"
add-apt-repository -y ppa:nijel/phpmyadmin >> ${logfile} 2>&1
echo -e "${YELLOW} Installing Apache / SQL / CertBot ${NC}"
(apt-get update) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPDATE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
(apt-get install -qq apache2 mysql-server python-certbot-apache) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[INSTALL:\n"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
echo -e "${YELLOW} Setup SQL Security ${NC}"
mysql_secure_installation --use-default --password=${ROOTPASSWD} >> ${logfile} 2>&1
echo -e "${YELLOW} Restarting Apache/MySQL ${NC}"
service mysql restart >> ${logfile} 2>&1
service apache2 restart >> ${logfile} 2>&1
echo -e "${YELLOW} Installing PHP Packages ${NC}"
#PHP Base Packages
(apt-get install -qq php7.2 php7.2-mysql php7.2-curl php7.2-xml php7.2-zip  php7.2-gd php7.2-common php7.2-json php7.2-opcache php7.2-readline php7.2-dev php7.2-mbstring php7.2-soap php7.2-xmlrpc php7.2-imap) >> ${logfile} & PID=$! 2>&1
#php-pear
    printf  "${GREEN}[INSTALL 1:\n"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
#PHP Secondary Packages
(apt-get install -qq libmcrypt-dev) >> ${logfile} & PID=$! 2>&1
# php-pecl
    printf  "${GREEN}[INSTALL 2:\n"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
#PHP 3rd Party Packages
(pecl -q install mcrypt-1.0.1) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[INSTALL 3:\n"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
echo -e "${YELLOW} Setting Up mcrypt ${NC}"
echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/mods-available/mcrypt.ini
cd /etc/php/7.2/cli/conf.d/ && ln -s /etc/php/7.2/mods-available/20-mcrypt.ini
cd /etc/php/7.2/apache2/conf.d/ && ln -s /etc/php/7.2/mods-available/20-mcrypt.ini
echo -e "${YELLOW} Restarting Apache/MySQL ${NC}"
service mysql restart >> ${logfile} 2>&1
service apache2 restart >> ${logfile} 2>&1
echo -e "${YELLOW} Installing Other QOL Packages ${NC}"
(apt-get install -qq mc sl screen htop) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[INSTALL:\n"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
echo -e "${YELLOW} Clean up and Updates ${NC}"
(apt-get update) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPDATE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
(apt-get upgrade -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPGRADE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"

(apt-get autoremove -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[AUTOREMOVE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
echo -e "${LGREEN} == Done == ${NC}"

#Setup user
echo -e "${BLUE}<== 2. Users & Passwords ==> ${NC}"

if [ ! -d /home/cl6 ]; then mkdir /home/cl6 ; fi
if [ ! -d /home/root ]; then mkdir /home/root ; fi

echo -e "${YELLOW} Setup User: clovisd ${NC}"
useradd clovisd -m -s /bin/bash
chpasswd<<<"clovisd:${CLPASSWD}"
htpasswd -c -b /opt/cl6/vault/.htpasswd clovisd ${CLPASSWD}
echo -e "${YELLOW} Setup User: cl6 ${NC}"
useradd cl6 -G www-data -s /bin/bash
chpasswd<<<"cl6:${C6PASSWD}"
htpasswd -b /opt/cl6/vault/.htpasswd cl6 ${C6PASSWD}

echo -e "${LGREEN} == Done == ${NC}"

#Setup Bash
echo -e "${BLUE}<== 3. Setup Bash ==> ${NC}"
echo -e "${YELLOW} Setting Up Bash for All Users ${NC}"
cp /opt/cl6/setup/.bashrc /home/clovisd/
cp /opt/cl6/setup/.bashrc /home/cl6/
cp /opt/cl6/setup/.bashrc /home/root/
echo -e "${LGREEN} == Done == ${NC}"

#Setup PHP
echo -e "${BLUE}<== 3. Setup PHP ==> ${NC}"
echo -e "${YELLOW} Copying Content to PHP.INI ${NC}"
PHPSETTINGS='[PHP]
#INSERT LOADERS HERE

#CUSTOM
date.timezone = "US/Central"
upload_max_filesize = 2048M
memory_limit = 512M
post_max_size = 8M
extension = mcrypt.so

#REST
engine = On
short_open_tag = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
serialize_precision = -1
disable_functions = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,
zend.enable_gc = On
expose_php = Off
max_execution_time = 30
max_input_time = 60
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
default_mimetype = "text/html"
default_charset = "UTF-8"
enable_dl = Off
file_uploads = On
max_file_uploads = 20
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60
[CLI Server]
cli_server.color = On
[Date]
[filter]
[iconv]
[intl]
[sqlite3]
[Pcre]
[Pdo]
[Pdo_mysql]
pdo_mysql.cache_size = 2000
[Phar]
[mail function]
SMTP = localhost
smtp_port = 25
mail.add_x_header = Off
[ODBC]
odbc.allow_persistent = On
odbc.check_persistent = On
odbc.max_persistent = -1
odbc.max_links = -1
odbc.defaultlrl = 4096
odbc.defaultbinmode = 1
[Interbase]
ibase.allow_persistent = 1
ibase.max_persistent = -1
ibase.max_links = -1
ibase.timestampformat = "%Y-%m-%d %H:%M:%S"
ibase.dateformat = "%Y-%m-%d"
ibase.timeformat = "%H:%M:%S"
[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.cache_size = 2000
mysqli.default_port = 3306
mysqli.reconnect = Off
[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off
[OCI8]
[PostgreSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0
[bcmath]
bcmath.scale = 0
[browscap]
[Session]
session.save_handler = files
session.use_strict_mode = 0
session.use_cookies = 1
session.use_only_cookies = 1
session.name = PHPSESSID
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly =
session.serialize_handler = php
session.gc_probability = 0
session.gc_divisor = 1000
session.gc_maxlifetime = 1440
session.referer_check =
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.sid_length = 26
session.trans_sid_tags = "a=href,area=href,frame=src,form="
session.sid_bits_per_character = 5[Assertion]
zend.assertions = -1
[COM]
[mbstring]
[gd]
[exif]
[Tidy]
tidy.clean_output = Off
[soap]
soap.wsdl_cache_enabled=1
soap.wsdl_cache_dir="/tmp"
soap.wsdl_cache_ttl=86400
soap.wsdl_cache_limit = 5
[sysvshm]
[ldap]
ldap.max_links = -1
[dba]
[opcache]
[curl]
[openssl]'
echo "${PHPSETTINGS}" > /etc/php/7.2/apache2/php.ini
echo "${PHPSETTINGS}" > /etc/php/7.2/cli/php.ini
echo -e "${YELLOW} Restarting Apache/MySQL ${NC}"
service apache2 restart >> ${logfile} 2>&1
#Setup permissions
echo -e "${BLUE}<== 4. Setup User Permissions ==> ${NC}"

SUDO="clovisd    ALL=(ALL:ALL) NOPASSWD:ALL
cl6    ALL=(ALL:ALL) ALL
"

echo "${SUDO}" > /etc/sudoers.d/cl6
echo -e "${LGREEN} == Done == ${NC}"

#Setup SSH Port
echo -e "${BLUE}<== 5. Setup SSH Settings ==> ${NC}"
echo -e "${YELLOW} Setting settings ${NC}"

SSHD="Port 42806
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp	/usr/lib/openssh/sftp-server"

echo "${SSHD}" > /etc/ssh/sshd_config

#nano /etc/ssh/sshd_config
#vi /etc/ssh/sshd_config
echo -e "${YELLOW} Restarting SSH Service ${NC}"
service sshd restart
echo -e "${LGREEN} == Done == ${NC}"

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

#SetupPHPAdmin
echo -e "${BLUE}<== 8. PHPMyAdmin ==> ${NC}"
(apt-get update) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPDATE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
(apt-get upgrade -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPGRADE:\n"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"

(apt-get autoremove -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[AUTOREMOVE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
echo -e "${YELLOW} Installing PHPMyAdmin ${NC}"
(DEBIAN_FRONTEND=noninteractive apt-get install -qq phpmyadmin) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[INSTALL:\n"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
echo -e "${YELLOW}Setting Auth File ${NC}"

AUTH='AuthType Basic
AuthName "Restricted Files"
AuthUserFile /opt/cl6/vault/.htpasswd
Require valid-user'

echo "${AUTH}" > /usr/share/phpmyadmin/.htaccess
echo -e "${YELLOW} Set ${GREEN}AllowOverride All${YELLOW} for PHPMYAdmin ${NC}"
echo -ne "${WHITE}Press Enter when ready!" ; read input
nano /etc/apache2/conf-available/phpmyadmin.conf
echo -e "${YELLOW} Enable Plugin ${NC}"
phpenmod mbstring
phpenmod mcrypt
echo -e "${YELLOW}Configure MySQL ${NC}"
#mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${ROOTPASSWD}';"
#mysql -u root -p"${ROOTPASSWD}" -e "FLUSH PRIVILEGES;"
#mysql -u root -p"${ROOTPASSWD}" -e "CREATE USER ‘clovisd’@’%’ IDENTIFIED BY ‘${CLPASSWD}’;"
#mysql -u root -p"${ROOTPASSWD}" -e "CREATE USER cl6@’%’ IDENTIFIED BY ‘${C6PASSWD}’;"
mysql -u root -p"${ROOTPASSWD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'clovisd'@'localhost' IDENTIFIED BY '${CLPASSWD}';"
mysql -u root -p"${ROOTPASSWD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'cl6'@'localhost' IDENTIFIED BY '${C6PASSWD}';"
#mysql -u root -p"${ROOTPASSWD}" -e "GRANT ALL PRIVILEGES ON *.* TO ‘clovisd’@’%’;"
#mysql -u root -p"${ROOTPASSWD}" -e "GRANT ALL PRIVILEGES ON *.* TO ‘cl6’@’%’;"
mysql -u root -p"${ROOTPASSWD}" -e "FLUSH PRIVILEGES;"
echo -e "${LGREEN} == Done == ${NC}"
​#Cleanup Apache
echo -e "${BLUE}<== 9. Cleanup Apache Configs ==> ${NC}"
cd /var/ && rm -R www
cd /etc/apache2/sites-enabled/ && rm -R *
cd /etc/apache2/sites-available/ && rm -R *

#Setup Host Directories
echo -e "${BLUE}<== 9. Setting Up Host Directories ==> ${NC}"
if [ ! -d /opt/cl6/hosting/ ]; then mkdir /opt/cl6/hosting/ ; fi
if [ ! -d /opt/cl6/hosting/s${SERVERNUM}.cl6.us ]; then mkdir /opt/cl6/hosting/s${SERVERNUM}.cl6.us ; fi
if [ ! -d /opt/cl6/hosting/s${SERVERNUM}.cl6.us/logs ]; then mkdir /opt/cl6/hosting/s${SERVERNUM}.cl6.us/logs ; fi
if [ ! -d /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html ]; then mkdir /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html ; fi
if [ ! -d /opt/cl6/hosting/s${SERVERNUM}.cl6.us/backup ]; then mkdir /opt/cl6/hosting/s${SERVERNUM}.cl6.us/backup ; fi
if [ ! -d /opt/cl6/hosting/s${SERVERNUM}.cl6.us/automation ]; then mkdir /opt/cl6/hosting/s${SERVERNUM}.cl6.us/automation ; fi
if [ ! -d /opt/cl6/hosting/example.com ]; then mkdir /opt/cl6/hosting/example.com ; fi
if [ ! -d /opt/cl6/hosting/example.com/logs ]; then mkdir /opt/cl6/hosting/example.com/logs ; fi
if [ ! -d /opt/cl6/hosting/example.com/html ]; then mkdir /opt/cl6/hosting/example.com/html ; fi
if [ ! -d /opt/cl6/hosting/example.com/backup ]; then mkdir /opt/cl6/hosting/example.com/backup ; fi
if [ ! -d /opt/cl6/hosting/example.com/automation ]; then mkdir /opt/cl6/hosting/example.com/automation ; fi
echo -e "${LGREEN} == Done == ${NC}"

#Setup Catch-All
echo -e "${BLUE}<== 11. Setup Catch-All Page ==> ${NC}"
if [ ! -d /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/catch-all ]; then mkdir /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/catch-all ; fi
echo -e "${YELLOW} Moving Archive ${NC}"
cp /opt/cl6/setup/catch-all.tar.gz /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/catch-all
cd /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/catch-all
echo -e "${YELLOW} Extracting Archive ${NC}"
tar -zxvf catch-all.tar.gz  >> ${logfile} 2>&1
rm catch-all.tar.gz
echo -e "${YELLOW} Creating Apache Conf ${NC}"

STATUSPAGE="<VirtualHost *:80>
	ServerName catch-all.cl6.us
	ServerAlias *.cl6.us
	ServerAlias *.cl6web.com
	ServerAlias www.*.cl6web.com
	ServerAlias www.*.cl6.us

	ServerAdmin webmaster@cl6.us
	DocumentRoot /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/catch-all
	
	ErrorLog /opt/cl6/hosting/s${SERVERNUM}.cl6.us/logs/catch-all.log
	CustomLog /opt/cl6/hosting/s${SERVERNUM}.cl6.us/logs/catch-all-custom.log combined

	<Directory /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/catch-all>
		AllowOverride All
		Require all granted
	</Directory>
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet"

echo "${STATUSPAGE}" > /etc/apache2/sites-available/catch-all.cl6.us.conf
echo -e "${YELLOW} Creating SymLink ${NC}"
cd /etc/apache2/sites-enabled && ln -s /etc/apache2/sites-available/catch-all.cl6.us.conf
echo -e "${YELLOW} Restarting Apache ${NC}"
service apache2 restart >> ${logfile} 2>&1
echo -e "${LGREEN} == Done == ${NC}"

#Setup Server Status
echo -e "${BLUE}<== 12. Setup Status Page ==> ${NC}"
echo -e "${YELLOW} Moving Archive ${NC}"
cp /opt/cl6/setup/status-page.tar.gz /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html
cd /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html
echo -e "${YELLOW} Extracting Archive ${NC}"
tar -zxvf status-page.tar.gz  >> ${logfile} 2>&1
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

echo "${STATUSPAGE}" > /etc/apache2/sites-available/s${SERVERNUM}.cl6.us.conf
echo -e "${YELLOW} Creating SymLink ${NC}"
cd /etc/apache2/sites-enabled && ln -s /etc/apache2/sites-available/s${SERVERNUM}.cl6.us.conf

echo -e "${BLUE}<== 13. Setup CertBot + CloudFlare ==> ${NC}"
echo -e "${YELLOW} Restarting Apache ${NC}"
service apache2 restart >> ${logfile} 2>&1
echo -e "${YELLOW} Creating A Records w/ CloudFlare ${NC}"

ZONE1=cl6.us
ZONE2=cl6web.com
DNSRECORD1=s${SERVERNUM}.cl6.us
DNSRECORD2=s${SERVERNUM}.cl6web.com

ZONEID1=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE1&status=active" \
  -H "X-Auth-Email: $CFEMAIL" \
  -H "X-Auth-Key: $CFK" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')
  
ZONEID2=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE2&status=active" \
  -H "X-Auth-Email: $CFEMAIL" \
  -H "X-Auth-Key: $CFK" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONEID1/dns_records" \
  -H "X-Auth-Email: $CFEMAIL" \
  -H "X-Auth-Key: $CFK" \
  -H "Content-Type: application/json" \
  --data '{"type":"A","name":"'"$DNSRECORD1"'","content":"'"$SERVERIP"'","proxied":false}' >> ${logfile} 2>&1
  
sleep 3s

curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONEID2/dns_records" \
  -H "X-Auth-Email: $CFEMAIL" \
  -H "X-Auth-Key: $CFK" \
  -H "Content-Type: application/json" \
  --data '{"type":"A","name":"'"$DNSRECORD2"'","content":"'"$SERVERIP"'","proxied":false}' >> ${logfile} 2>&1
  
sleep 3s
echo -e "${LGREEN} == Done == ${NC}"
echo -e "${YELLOW} Generating CertBot Certs ${NC}"
#certbot --apache-n -d s${SERVERNUM}.cl6.us -d s${SERVERNUM}.cl6web.com
#certbot certonly -m ssl@cl6web.com --agree-tos --no-eff-email --redirect --webroot -w /home/cl6web/s${SERVERNUM}.cl6.us/status -d s${SERVERNUM}.cl6.us -d s${SERVERNUM}.cl6web.com
certbot run -m ssl@cl6web.com --agree-tos --no-eff-email --redirect -a webroot -i apache -w /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html -d s${SERVERNUM}.cl6.us -d s${SERVERNUM}.cl6web.com >> ${logfile} 2>&1

echo -e "${YELLOW} Setting HTACCESS File ${NC}"
echo "${AUTH}" > /opt/cl6/hosting/s${SERVERNUM}.cl6.us/.htaccess
​echo -e "${LGREEN} == Done == ${NC}"

#CRON SSL Renew
crontab="0 0 1 * * certbot renew  >/dev/null 2>&1"
#crontab -e root
crontab -u root -l; echo "$crontab" | crontab -u root - >> ${logfile} 2>&1

#CleanUp
#sudo rm -R /home/scripts/setup

#Reboot
(apt-get update) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPDATE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"

(apt-get upgrade -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPGRADE:\n"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"

(apt-get autoremove -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[AUTOREMOVE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"

(apt-get autoclean -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[AUTOCLEAN:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
echo -e "${YELLOW} Discord Ping ${NC}"
cd /opt/cl6/setup && ./discord.sh

echo -e "${BLUE}<== 14. Setup Swap ==> ${NC}"



echo -ne "${WHITE}Press Enter when Reboot Ready!${NC}" ; read input
reboot
