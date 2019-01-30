#!/bin/bash
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/home/scripts/logs/loader.out 2>&1
#set -x
#set +x

#bash <(wget -O- -q https://raw.githubusercontent.com/clovisd/CL6-Scripts/master/loader.sh)
#bash <(wget -O- -q https://goo.gl/yf18Rh)

#Color Codes
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
LGREEN='\033[1;32m'
WHITE='\033[1;37m'

DEBIAN_FRONTEND=noninteractive
echo -e "\n
${RED}   ____ _     __   _   _ ____  
${RED}  / ___| |   / /_ | | | / ___| 
${RED} | |   | |  | '_ \| | | \___ \ 
${RED} | |___| |__| (_) | |_| |___) |
${RED} \____|_____\___(_)___/|____/ "
echo -e "${GREEN}<== CL6 Server Loader Script ==>"
echo -e "${LGREEN} v2.4 - clovisd"
echo -ne "${RED}Press Enter when ready!${NC}" ; read input
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
(apt-get update -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPDATE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
(apt-get remove --purge -qq postfix apache2) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[REMOVE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
(apt-get install -qq git software-properties-common dnsutils dbus tzdata nano) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[INSTALL:\n"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
echo -e "${LGREEN} >> Done"

#SetTimeZone
echo -e "${YELLOW} >> Setting Timezone"
timedatectl set-timezone America/Denver >> ${logfile} 2>&1
locale-gen en_US.UTF-8 >> ${logfile} 2>&1
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
echo -e "${LGREEN} >> Done"

echo -e "${YELLOW} >> Cloning from GitHub"
git clone https://github.com/clovisd/CL6-Scripts.git /home/scripts/setup >> ${logfile} 2>&1
echo -e "${LGREEN} >> Done"

echo -e "${YELLOW} >> Setting Permissions"
chmod a+x -R /home/scripts/setup/setup.sh
echo -e "${LGREEN} >> Done"

#DetectOS
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

echo "${OS}" > /home/scripts/setup/os.info
echo "${VER}" > /home/scripts/setup/ver.info

#Run Install
echo -e "${BLUE} ===>> Running Setup Script <<===${NC}"
cd /home/scripts/setup && ./setup.sh