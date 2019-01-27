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
echo -e "${LGREEN} v1.2 - clovisd"
echo -e "${YELLOW} >> Checking Root"
#Check Root
if [[ $EUID -ne 0 ]]; then
  echo "${RED} Need Root to Run! Please try running as Root again."
  exit 1
else
  echo -e "${LGREEN} Running with Root."
fi

#Log File
logfile="/home/scripts/logs/loader.log"

#Setup Base Programs
echo -e "${YELLOW} >> Installing Programs"
apt-get --assume-yes -qq -y update >> ${logfile} 2>&1
apt-get --assume-yes -qq -y upgrade >> ${logfile} 2>&1
apt-get --assume-yes -qq -y install git dig software-properties-common
echo -e "${LGREEN} >> Done"

#Setup Files & Directories
echo -e "${YELLOW} >> Setting up Directories"
if [ ! -d /home/scripts ]; then mkdir /home/scripts ; fi
if [ ! -d /home/scripts/setup ]; then mkdir /home/scripts/setup ; fi
if [ ! -d /home/scripts/logs ]; then mkdir /home/scripts/logs ; fi
echo -e "${LGREEN} >> Done"

echo -e "${YELLOW} >> Cloning from GitHub"
git clone https://github.com/clovisd/CL6-Scripts.git /home/scripts/setup >> ${logfile} 2>&1
echo -e "${LGREEN} >> Done"

echo -e "${YELLOW} >> Setting Permissions"
chmod a+x -R /home/scripts
echo -e "${LGREEN} >> Done"

#Run Install
echo -e "${BLUE} ===>> Running Setup Script <<==="
cd /home/scripts/setup && ./setup.sh