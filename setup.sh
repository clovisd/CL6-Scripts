#!/bin/bash
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/home/scripts/logs/setup.out 2>&1
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

#Prompt for Server Info
echo -ne "${WHITE}Please enter the S# name scheme: " ; read input
if [[ -z $input ]]; then
    echo "No Value Entered. Exiting."
	exit 1
else
    SERVERNUM=${input}
    echo "Server Name Set to: S${input}.CL6.US (S${SERVERNUM}.CL6WEB.COM)"
fi
echo -ne "${RED}>> clovisd account info:${NC}"
echo ""
read -s -p "Enter Password:" clpasswd
if [[ -z $clpasswd ]]; then
    echo "No Value Entered. Exiting."
	exit 1
else
    echo "clovisd:$clpasswd" > /home/scripts/setup/clovisd.info
fi
echo ""
echo -ne "${RED}>> Cl6Web account info:${NC}"
echo ""
read -s -p "Enter Password:" c6passwd
if [[ -z $c6passwd ]]; then
    echo "No Value Entered. Exiting."
	exit 1
else
    echo "cl6web:$c6passwd" > /home/scripts/setup/cl6web.info
fi
echo ""
echo -ne "${RED}>> Root account info:${NC}"
echo ""
read -s -p "Enter Password:" rootpasswd
if [[ -z $rootpasswd ]]; then
    echo "No Value Entered. Exiting."
	exit 1
else
    echo "root:$rootpasswd" > /home/scripts/setup/root.info
fi
echo ""

#FigureOut IP
SERVERIP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
echo "Server IP is: ${SERVERIP}"

#Setup Updates for New Server
echo -e "${BLUE}<== 1. Updates & Upgrades ==> ${NC}"
apt-get --assume-yes -qq update & PID=$! >> ${logfile} 2>&1
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN} Update Done!${NC}"
apt-get --assume-yes -qq upgrade & PID=$! >> ${logfile} 2>&1
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN} Upgrade Done!${NC}"
apt-get --assume-yes -qq autoremove & PID=$! >> ${logfile} 2>&1
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN} Autoremove Done!${NC}"
echo -e "${LGREEN}== Done == ${NC}"

#Install Packages
echo -e "${BLUE}<== 7. Install Apps & Packages ==> ${NC}"
echo -e "${YELLOW} Setting up CertBot Repo ${NC}"
sudo add-apt-repository -y ppa:certbot/certbot
echo -e "${YELLOW} Setting up PHPMyAdmin Repo ${NC}"
sudo add-apt-repository -y ppa:nijel/phpmyadmin
echo -e "${YELLOW} Installing Apache / SQL / CertBot ${NC}"
apt-get --assume-yes -qq -y install apache2 mysql-server python-certbot-apache >> ${logfile} 2>&1
apt-get --assume-yes -qq -y update >> ${logfile} 2>&1
apt-get --assume-yes -qq -y upgrade >> ${logfile} 2>&1
echo -e "${YELLOW} Setup SQL Security ${NC}"
mysql_secure_installation --use-default --password=${rootpasswd}
echo -e "${YELLOW} Restarting Apache/MySQL ${NC}"
service mysql restart | tee -a "$logfile"
service apache2 restart | tee -a "$logfile"
echo -e "${YELLOW} Installing PHP Packages ${NC}"
apt-get --assume-yes -qq -y install hp php7.2-mysql php7.2-curl php7.2-xml php7.2-zip  php7.2-gd php7.2-common php7.2-json php7.2-opcache php7.2-readline php7.2-dev php7.2-mbstring php7.2-soap php7.2-xmlrpc php7.2-imap php-pear >> ${logfile} 2>&1
echo -e "${YELLOW} Restarting Apache/MySQL ${NC}"
service mysql restart | tee -a "$logfile"
service apache2 restart | tee -a "$logfile"
echo -e "${YELLOW} Installing Personal Packages ${NC}"
apt-get --assume-yes -qq -y install mc sl screen htop >> ${logfile} 2>&1
echo -e "${LGREEN}== Done == ${NC}"

#Setup user
echo -e "${BLUE}<== 2. Users & Passwords ==> ${NC}"

if [ ! -d /home/cl6web ]; then mkdir /home/cl6web ; fi

echo -e "${YELLOW} Setup User: clovisd ${NC}"
useradd clovisd -m -s /bin/bash
chpasswd<<<"clovisd:${clpasswd}"
htpasswd -c -b /home/cl6web/.htpasswd clovisd ${clpasswd}
​echo -e "${YELLOW} Setup User: cl6web ${NC}"
useradd cl6web -G www-data -s /bin/bash
chpasswd<<<"cl6web:${c6passwd}"
htpasswd -b /home/cl6web/.htpasswd cl6web ${c6passwd}

echo -e "${LGREEN}== Done == ${NC}"

#Setup Bash
echo -e "${BLUE}<== 3. Setup Bash ==> ${NC}"
echo -e "${YELLOW} Setting Up Bash for All Users ${NC}"
cp /home/scripts/setup/.bashrc /home/clovisd/
cp /home/scripts/setup/.bashrc /home/cl6web/
if [ ! -d /home/root ]; then mkdir /home/root ; fi
cp /home/scripts/setup/.bashrc /home/root/
echo -e "${LGREEN}== Done == ${NC}"

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
echo "${PHP}" > /etc/php/7.2/apach2/php.ini

echo -e "${YELLOW} Restarting Apache/MySQL ${NC}"
service apache2 restart | tee -a "$logfile"

#Setup permissions
echo -e "${BLUE}<== 4. Setup User Permissions ==> ${NC}"

SUDO="clovisd    ALL=(ALL:ALL) NOPASSWD:ALL
cl6web    ALL=(ALL:ALL) ALL
"

echo "${SUDO}" > /etc/sudoers.d/cl6
echo -e "${LGREEN}== Done == ${NC}"

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
echo -e "${LGREEN}== Done == ${NC}"

#Setup Hosts
echo -e "${BLUE}<== 6. Set Server Name & Hosts ==> ${NC}"
echo -e "${GREEN} Set Hostname ${NC}"

HOSTNAME="S${SERVERNUM}"

echo "${HOSTNAME}" > /etc/hostname
#nano /etc/hostname
echo -e "${GREEN} Set Hosts ${NC}"

HOSTS="# Basic Hosts
127.0.1.1 CL6-${SERVERNUM}.localdomain CL6-${SERVERNUM}
127.0.1.1 S${SERVERNUM}.cl6.us CL6-${SERVERNUM}
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
echo -e "${LGREEN}== Done == ${NC}"

#SetupPHPAdmin
echo -e "${BLUE}<== 8. PHPMyAdmin ==> ${NC}"
apt-get --assume-yes -qq update
apt-get --assume-yes -qq upgrade
apt-get --assume-yes -qq autoremove
echo -e "${YELLOW} Installing PHPMyAdmin ${NC}"
apt-get --assume-yes -qq -y install phpmyadmin
echo -e "${YELLOW}Setting Auth File ${NC}"

AUTH='AuthType Basic
AuthName "Restricted Files"
AuthUserFile /home/cl6web/.htpasswd
Require valid-user'

echo "${AUTH}" > /usr/share/phpmyadmin/.htaccess
echo -e "${YELLOW} Set AllowOverride All for PHPMYAdmin ${NC}"
echo -ne "${WHITE}Press Enter when ready!" ; read input
nano /etc/apache2/conf-available/phpmyadmin.conf
echo -e "${YELLOW} Enable Plugin ${NC}"
phpenmod mbstring
echo -e "${YELLOW}Configure MySQL ${NC}"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${rootpasswd}';"
mysql -u root -p"${rootpasswd}" -e "FLUSH PRIVILEGES;"
​echo -e "${LGREEN}== Done == ${NC}"
​
#Cleanup Apache
echo -e "${BLUE}<== 9. Cleanup Apache Configs ==> ${NC}"
cd /var/ && rm -R www
cd /etc/apache2/sites-enabled/ && rm -R *
cd /etc/apache2/sites-available/ && rm -R *

#Setup Host Directories
echo -e "${BLUE}<== 9. Setting Up Host Directories ==> ${NC}"
if [ ! -d /home/cl6web ]; then mkdir /home/cl6web ; fi
if [ ! -d /home/cl6web/s${SERVERNUM}.cl6.us ]; then mkdir /home/cl6web/s${SERVERNUM}.cl6.us ; fi
if [ ! -d /home/cl6web/s${SERVERNUM}.cl6.us/logs ]; then mkdir /home/cl6web/s${SERVERNUM}.cl6.us/logs ; fi
if [ ! -d /home/cl6web/example.com ]; then mkdir /home/cl6web/example.com ; fi
if [ ! -d /home/cl6web/example.com/logs ]; then mkdir /home/cl6web/example.com/logs ; fi
if [ ! -d /home/cl6web/example.com/html ]; then mkdir /home/cl6web/example.com/html ; fi
if [ ! -d /home/cl6web/example.com/backup ]; then mkdir /home/cl6web/example.com/backup ; fi
if [ ! -d /home/cl6web/example.com/automation ]; then mkdir /home/cl6web/example.com/automation ; fi
echo -e "${LGREEN}== Done == ${NC}"

#Setup CL6 Greeter Page
echo -e "${BLUE}<== 11. Setup Greeter Page ==> ${NC}"
if [ ! -d /home/scripts/setup/greeter ]; then mkdir /home/scripts/setup/greeter ; fi
echo -e "${YELLOW} Moving Archive ${NC}"
cp /home/scripts/setup/greeter.tar.gz /home/scripts/setup/greeter
cd /home/scripts/setup/greeter
echo -e "${YELLOW} Extracting Archive ${NC}"
tar -zxvf greeter.tar.gz | tee -a "$logfile"
rm greeter.tar.gz
if [ ! -d /home/cl6web/s${SERVERNUM}.cl6.us/greeter ]; then mkdir /home/cl6web/s${SERVERNUM}.cl6.us/greeter ; fi
echo -e "${YELLOW} Moving Files ${NC}"
cp -R /home/scripts/setup/greeter/ /home/cl6web/s${SERVERNUM}.cl6.us/
echo -e "${YELLOW} Creating Apache Conf ${NC}"

STATUSPAGE="<VirtualHost *:80>
	ServerName util.cl6.us
	ServerAlias *.cl6.us
	ServerAlias *.cl6web.com
	ServerAlias www.*.cl6web.com
	ServerAlias www.*.cl6.us

	ServerAdmin webmaster@cl6.us
	DocumentRoot /home/cl6web/s${SERVERNUM}.cl6.us/greeter
	
	ErrorLog /home/cl6web/s${SERVERNUM}.cl6.us/logs/greeterpage.log
	CustomLog /home/cl6web/s${SERVERNUM}.cl6.us/logs/greeterpage-custom.log combined

	<Directory /home/cl6web/s${SERVERNUM}.cl6.us/greeter>
		AllowOverride All
		Require all granted
	</Directory>
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet"

echo "${STATUSPAGE}" > /etc/apache2/sites-available/util.cl6.us.conf
echo -e "${YELLOW} Creating SymLink ${NC}"
cd /etc/apache2/sites-enabled && ln -s /etc/apache2/sites-available/util.cl6.us.conf
echo -e "${YELLOW} Restarting Apache ${NC}"
service apache2 restart | tee -a "$logfile"
echo -e "${LGREEN}== Done == ${NC}"

#Setup Server Status
echo -e "${BLUE}<== 12. Setup Status Page ==> ${NC}"
if [ ! -d /home/scripts/setup/status ]; then mkdir /home/scripts/setup/status ; fi
echo -e "${YELLOW} Moving Archive ${NC}"
cp /home/scripts/setup/status.tar.gz /home/scripts/setup/status
cd /home/scripts/setup/status
echo -e "${YELLOW} Extracting Archive ${NC}"
tar -zxvf status.tar.gz | tee -a "$logfile"
rm status.tar.gz
if [ ! -d /home/cl6web/s${SERVERNUM}.cl6.us/status ]; then mkdir /home/cl6web/s${SERVERNUM}.cl6.us/status ; fi
echo -e "${YELLOW} Moving Files ${NC}"
cp -R /home/scripts/setup/status/ /home/cl6web/s${SERVERNUM}.cl6.us/
echo -e "${YELLOW} Creating Apache Conf ${NC}"

STATUSPAGE="<VirtualHost *:80>
	ServerName s${SERVERNUM}.cl6.us
	ServerAlias s${SERVERNUM}.cl6web.com
	ServerAlias www.s${SERVERNUM}.cl6web.com
	ServerAlias www.s${SERVERNUM}.cl6.us

	ServerAdmin webmaster@cl6.us
	DocumentRoot /home/cl6web/s${SERVERNUM}.cl6.us/status
	
	ErrorLog /home/cl6web/s${SERVERNUM}.cl6.us/logs/statuspage.log
	CustomLog /home/cl6web/s${SERVERNUM}.cl6.us/logs/statuspage-custom.log combined

	<Directory /home/cl6web/s${SERVERNUM}.cl6.us/status>
		AllowOverride All
		Require all granted
	</Directory>
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet"

echo "${STATUSPAGE}" > /etc/apache2/sites-available/s${SERVERNUM}.cl6.us.conf
echo -e "${YELLOW} Creating SymLink ${NC}"
cd /etc/apache2/sites-enabled && ln -s /etc/apache2/sites-available/s${SERVERNUM}.cl6.us.conf
echo -e "${YELLOW} Restarting Apache ${NC}"
service apache2 restart | tee -a "$logfile"
echo -ne "${WHITE}Press Enter when DNS ready!" ; read input
echo -e "${YELLOW} Generating Certificate ${NC}"

#certbot --apache-n -d s${SERVERNUM}.cl6.us -d s${SERVERNUM}.cl6web.com
#certbot certonly -m ssl@cl6web.com --agree-tos --no-eff-email --redirect --webroot -w /home/cl6web/s${SERVERNUM}.cl6.us/status -d s${SERVERNUM}.cl6.us -d s${SERVERNUM}.cl6web.com
certbot run -m ssl@cl6web.com --agree-tos --no-eff-email --redirect -a webroot -i apache -w /home/cl6web/s${SERVERNUM}.cl6.us/status -d s${SERVERNUM}.cl6.us -d s${SERVERNUM}.cl6web.com

echo -e "${YELLOW} Setting HTACCESS File ${NC}"
echo "${AUTH}" > /home/cl6web/s${SERVERNUM}.cl6.us/status/.htaccess
​echo -e "${LGREEN}== Done == ${NC}"

#CRON SSL Renew
crontab="0 0 1 * * certbot renew  >/dev/null 2>&1"
crontab -u root -l; echo "$crontab"  | crontab -u root -

#CleanUp
#sudo rm -R /home/scripts/setup

#Reboot
apt-get --assume-yes -qq -y update >> ${logfile} 2>&1
apt-get --assume-yes -qq -y upgrade >> ${logfile} 2>&1
apt-get --assume-yes -qq -y autoremove >> ${logfile} 2>&1
echo -ne "${WHITE}Press Enter when Reboot Ready!" ; read input
reboot
