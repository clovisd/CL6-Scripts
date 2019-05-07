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

echo "PhJ8aVhELucAAAAAAAAf6BiZQyAListht0eyuPBTRIPDTgQpGgz7watW7-Imh-7S" > /opt/cl6/vault/dbtoken.vault

#Check Root
if [[ $EUID -ne 0 ]]; then
  echo "Need Root to Run! Please try running as Root again."
  exit 1
fi

#Log File
logfile="/opt/cl6/logs/openvpnpatch.log"

#Color Codes
RED='\033[0;31m' #Error
YELLOW='\033[1;33m' #Doing Something
GREEN='\033[0;32m' #Auto Something
BLUE='\033[1;34m' #Headline
LGREEN='\033[1;32m' #Completed
NC='\033[0m'
WHITE='\033[1;37m'

DBTOKEN=$(</opt/cl6/vault/dbtoken.vault)
SERVERNUM=$(</opt/cl6/info/servernum.info)

echo ""
echo "Checking for IPv6 connectivity..."
echo ""
# "ping6" and "ping -6" availability varies depending on the distribution
if type ping6 > /dev/null 2>&1; then
	PING6="ping6 -c3 ipv6.google.com > /dev/null 2>&1"
else
	PING6="ping -6 -c3 ipv6.google.com > /dev/null 2>&1"
fi
if eval "$PING6"; then
	echo -e "${LGREEN} >> ${GREEN}Your host appears to have IPv6 connectivity.${NC}"
	SUGGESTION="y"
else
	echo -e "${LGREEN} >> ${RED} Your host does not appear to have IPv6 connectivity.${NC}"
	SUGGESTION="n"
fi

echo -e "${YELLOW} IPv6 Support Set to: ${SUGGESTION}${NC}"
echo -e "${YELLOW} Setting Install Variables${NC}"
#echo -ne "${RED}Press Enter when ready!${NC}" ; read -r input

export AUTO_INSTALL=y
export PORT_CHOICE=2
export PORT=42807
export PROTOCOL_CHOICE=1
export DNS=3
export CUSTOMIZE_ENC=n
export CLIENT=s$SERVERNUM
export PASS=1
export IPV6_SUPPORT=$SUGGESTION


echo -e "${YELLOW} Setting Up Tun!${NC}"
cd /dev || return
mkdir net
mknod net/tun c 10 200
chmod 0666 net/tun

echo -e "${YELLOW} Ready to run script!${NC}"
#echo -ne "${RED}Press Enter when ready!${NC}" ; read -r input

cd /opt/cl6/setup || return
wget https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod a+x openvpn-install.sh

./openvpn-install.sh >> ${logfile} & PID=$! 2>&1
	printf  "${GREEN}RUNNING SCRIPT:"
while kill -0 $PID 2> /dev/null; do 
	printf  "▄"
	sleep 3
done
printf "${GREEN}${NC} - Done\n"

#./openvpn-install.sh >> ${logfile} 2>&1

echo -e "${YELLOW} Done. Waiting for timer.${NC}"
sleep 3

echo -e "${YELLOW} Setting Admin User Variables${NC}"
#echo -ne "${RED}Press Enter when ready!${NC}" ; read -r input

export MENU_OPTION=1
export AUTO_INSTALL=n
export CLIENT=clovisd
export PASS=2

echo -e "${YELLOW} Ready to run script!${NC}"
#echo -ne "${RED}Press Enter when ready!${NC}" ; read -r input

./openvpn-install.sh >> ${logfile} & PID=$! 2>&1
	printf  "${GREEN}RUNNING SCRIPT:"
while kill -0 $PID 2> /dev/null; do 
	printf  "▄"
	sleep 3
done
printf "${GREEN}${NC} - Done\n"

echo -e "${YELLOW} Done. Waiting for timer.${NC}"
sleep 3

echo -e "${YELLOW} Ready to Setup Files!${NC}"
#echo -ne "${RED}Press Enter when ready!${NC}" ; read -r input

mkdir /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/status/vpn
cp /opt/cl6/setup/fancy-index/.htaccess-vpn /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/status/vpn/.htaccess
rm /opt/cl6/setup/fancy-index/.htaccess-vpn

cp /home/clovisd/s${SERVERNUM}.ovpn /home/clovisd/s${SERVERNUM}.cl6.us-public.ovpn
rm /home/clovisd/s${SERVERNUM}.ovpn

cp /home/clovisd/clovisd.ovpn /home/clovisd/s${SERVERNUM}.cl6.us-clovisd.ovpn
rm /home/clovisd/clovisd.ovpn

cp /home/clovisd/s${SERVERNUM}.cl6.us-clovisd.ovpn /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/status/vpn
cp /home/clovisd/s${SERVERNUM}.cl6.us-public.ovpn /opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/status/vpn

chown -R www-data:www-data /opt/cl6/hosting/

echo -e "\n${YELLOW} Ready to Dropbox Upload #1!${NC}"
#echo -ne "${RED}Press Enter when ready!${NC}" ; read -r input

cd /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html/status/vpn || return
curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $DBTOKEN" \
    --header "Dropbox-API-Arg: {\"path\": \"/Apps/CL6 Sync/VPN/s$SERVERNUM.cl6.us-clovisd.ovpn\"}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @s${SERVERNUM}.cl6.us-clovisd.ovpn >> ${logfile} 2>&1
	
echo -e "\n${YELLOW} Ready to Dropbox Upload #2!${NC}"
#echo -ne "${RED}Press Enter when ready!${NC}" ; read -r input

cd /opt/cl6/hosting/s"${SERVERNUM}".cl6.us/html/status/vpn || return
curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $DBTOKEN" \
    --header "Dropbox-API-Arg: {\"path\": \"/Apps/CL6 Sync/VPN/s$SERVERNUM.cl6.us-public.ovpn\"}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @"/opt/cl6/hosting/s${SERVERNUM}.cl6.us/html/status/vpn/s${SERVERNUM}.cl6.us-public.ovpn" >> ${logfile} 2>&1

echo -e "${LGREEN} >> ${GREEN} Done!"
echo -ne "${RED}Press Enter when ready!${NC}" ; read -r input

exit