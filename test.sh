#!/bin/bash
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/home/scripts/logs/loader.out 2>&1
#set -x
#set +x

#bash <(wget -O- -q https://raw.githubusercontent.com/clovisd/CL6-Scripts/master/test.sh)

#Color Codes
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
LGREEN='\033[1;32m'
WHITE='\033[1;37m'

#Check Root
if [[ $EUID -ne 0 ]]; then
  echo "${RED} Need Root to Run! Please try running as Root again."
  exit 1
else
  echo -e "${LGREEN} Running with Root."
fi

DEBIAN_FRONTEND=noninteractive

#Log File
logfile="/home/test.log"

echo -e "Please select Install Type:"

#Setup Base Programs
PS3='Select Install Type: '
options=("🔼 DigitalOcean" "🔼 GoogleCloud" "🔼 SparkVPS" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "🔼 DigitalOcean")
            echo "you chose choice 1"
            ;;
        "🔼 GoogleCloud")
            echo "you chose choice 2"
            ;;
        "🔼 SparkVPS")
            echo "you chose choice 3"
            ;;
        "Exit")
            break
            ;;
        *) echo invalid option;;
    esac
done