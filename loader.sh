#!/bin/bash
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/home/scripts/logs/loader.out 2>&1
#set -x
#set +x

#bash <(wget -O- -q https://raw.githubusercontent.com/clovisd/CL6-Scripts/master/loader.sh)

#Color Codes
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
LGREEN='\033[1;32m'
WHITE='\033[1;37m'

echo -e "${GREEN}<== CL6 Server Setup Script ==>"
echo -e "${LGREEN} v1.5 - clovisd"
echo -e "${YELLOW} >> Checking Root"
#Check Root
if [[ $EUID -ne 0 ]]; then
  echo "${RED} Need Root to Run! Please try running as Root again."
  exit 1
else
  echo -e "${LGREEN} Running with Root."
fi

#Setup Files & Directories
echo -e "${YELLOW} >> Setting up Directories"
if [ ! -d /home/scripts ]; then mkdir /home/scripts ; fi
if [ ! -d /home/scripts/setup ]; then mkdir /home/scripts/setup ; fi
if [ ! -d /home/scripts/logs ]; then mkdir /home/scripts/logs ; fi
echo -e "${LGREEN} >> Done"

#Log File
logfile="/home/scripts/logs/loader.log"

#Setup Base Programs
echo -e "${YELLOW} >> Installing Programs"
echo -ne "${WHITE}Initilized." ; read input
DEBIAN_FRONTEND=noninteractive
echo -ne "${WHITE}Interactivity Disabled." ; read input
apt-get --assume-yes -qq update #>> ${logfile}
echo -ne "${WHITE}Update Run." ; read input
apt-get --assume-yes -qq --purge remove postfix apache2 screen #>> ${logfile}
echo -ne "${WHITE}Uninstall Run." ; read input
apt-get --assume-yes -qq upgrade #>> ${logfile}
echo -ne "${WHITE}Upgrade Run." ; read input
apt-get  --assume-yes -qq install git software-properties-common dnsutils nano tzdata
echo -ne "${WHITE}Basic Utilities Installed" ; read input
echo -e "${LGREEN} >> Done"

#SetTimeZone
echo -e "${YELLOW} >> Setting Timezone"
timedatectl set-timezone America/Denver
echo -e "${LGREEN} >> Done"

echo -e "${YELLOW} >> Cloning from GitHub"
git clone https://github.com/clovisd/CL6-Scripts.git /home/scripts/setup >> ${logfile} 2>&1
echo -e "${LGREEN} >> Done"

echo -e "${YELLOW} >> Setting Permissions"
chmod a+x -R /home/scripts/setup/setup.sh
echo -e "${LGREEN} >> Done"

#Run Install
echo -e "${BLUE} ===>> Running Setup Script <<==="
cd /home/scripts/setup && ./setup.sh