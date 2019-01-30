#!/bin/bash
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/home/scripts/logs/loader.out 2>&1
#set -x
#set +x

#Check Root
if [[ $EUID -ne 0 ]]; then
  echo "${RED} Need Root to Run! Please try running as Root again."
  exit 1
else
  echo -e "${LGREEN} Running with Root."
fi

DEBIAN_FRONTEND=noninteractive

#Log File
logfile="/home/scripts/logs/test.log"

#Color Codes
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
LGREEN='\033[1;32m'
WHITE='\033[1;37m'

#Setup Base Programs
echo -e "${YELLOW} >> Installing Programs"

(apt-get update -qq & PID=$!) >> ${logfile} 2>&1
    printf  "${GREEN}[UPDATE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
(apt-get upgrade -qq & PID=$!) >> ${logfile} 2>&1
    printf  "${GREEN}[REMOVE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
(apt-get install -qq git software-properties-common dnsutils dbus tzdata nano & PID=$!) >> ${logfile} 2>&1
    printf  "${GREEN}[INSTALL:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"
echo -e "${LGREEN} >> Done"