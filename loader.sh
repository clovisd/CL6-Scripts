#!/bin/bash
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/opt/cl6/logs/loader_exec.log 2>&1
#set -x
#set +x

#bash <(wget -O- -q https://raw.githubusercontent.com/clovisd/CL6-Scripts/master/loader.sh)
#bash <(wget -O- -q https://goo.gl/yf18Rh)
#clear && bash <(wget -O- -q https://goo.gl/yf18Rh)

V='v2.8.4'

#Color Codes
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
LGREEN='\033[1;32m'
WHITE='\033[1;37m'

export DEBIAN_FRONTEND=noninteractive

echo -e "\n
${RED}   ____ _     __   _   _ ____  
${RED}  / ___| |   / /_ | | | / ___| 
${RED} | |   | |  | '_ \| | | \___ \ 
${RED} | |___| |__| (_) | |_| |___) |
${RED}  \____|_____\___(_)___/|____/ \n"
echo -e "${GREEN}<== CL6 Server Loader Script ==>"
echo -e "${LGREEN} ${V} - clovisd"
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
if [ ! -d /opt/cl6 ]; then mkdir /opt/cl6 ; fi
if [ ! -d /opt/cl6/setup ]; then mkdir /opt/cl6/setup ; fi
if [ ! -d /opt/cl6/logs ]; then mkdir /opt/cl6/logs ; fi
if [ ! -d /opt/cl6/info ]; then mkdir /opt/cl6/info ; fi
if [ ! -d /opt/cl6/vault ]; then mkdir /opt/cl6/vault ; fi
if [ ! -d /opt/cl6/hosting ]; then mkdir /opt/cl6/hosting ; fi
if [ ! -d /opt/cl6/locks ]; then mkdir /opt/cl6/locks ; fi
echo -e "${LGREEN} >> Done"

#Log File
logfile="/opt/cl6/logs/loader.log"

#SetTimeZone
echo -e "${YELLOW} >> Setting Timezone"
timedatectl set-timezone America/Denver >> ${logfile} 2>&1
locale-gen en_US.UTF-8 >> ${logfile} 2>&1
#export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
echo -e "${LGREEN} >> Done"

#Setup Base Programs
echo -e "${YELLOW} >> Installing Programs"
(apt-get update -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPDATE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
(apt-get remove --purge -qq postfix* apache2*) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[REMOVE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
(apt-get install -qq git software-properties-common dnsutils dbus tzdata nano jq curl) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[INSTALL:\n"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
echo -e "${LGREEN} >> Done"

echo -e "${YELLOW} >> Cloning from GitHub"
git clone https://github.com/clovisd/CL6-Scripts.git /opt/cl6/setup >> ${logfile} 2>&1
echo -e "${LGREEN} >> Done"

echo -e "${YELLOW} >> Setting Permissions"
chmod a+x -R /opt/cl6/setup/setup.sh
chmod a+x -R /opt/cl6/setup/discord.sh
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

echo "${OS}" > /opt/cl6/info/os.info
echo "${VER}" > /opt/cl6/info/ver.info
echo "${V}" > /opt/cl6/info/cl6v.info

#Run Install
echo -e "${BLUE} ===>> Running Setup Script <<===${NC}"
cd /opt/cl6/setup && ./setup.sh