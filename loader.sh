#!/bin/bash

#Check Root
if [[ $EUID -ne 0 ]]; then
  echo "Need Root to Run! Please try running as Root again."
  exit 1
fi

#set -x
#set +x

#Color Codes
RED='\033[0;31m'
LG='\033[0m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
LGREEN='\033[1;32m'
WHITE='\033[1;37m'
LG='\033[0;37m'

#Log File
logfile="setup.log"

#Setup Files & Directories
if [ ! -d /home/scripts ]; then mkdir /home/scripts ; fi
if [ ! -d /home/scripts/setup ]; then mkdir /home/scripts/setup ; fi
if [ ! -d /home/scripts/logs ]; then mkdir /home/scripts/logs ; fi

git clone https://github.com/clovisd/CL6-Scripts.git /home/scripts/setup >> ${logfile} 2>&1

chmod a+x -R /home/scripts

#Run Install
./home/scripts/setup.sh