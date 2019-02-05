#!/bin/bash
source base.sh
debug 0
logs cloudflare

function cf-add {

DOMAIN=$1
CFK=$2
CFEMAIL=$3
TYPE=$4
NAME=$5
IP=$6
PROXY=$7


ZONEID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN&status=active" \
  -H "X-Auth-Email: $CFEMAIL" \
  -H "X-Auth-Key: $CFK" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

sleep 1

curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records" \
  -H "X-Auth-Email: $CFEMAIL" \
  -H "X-Auth-Key: $CFK" \
  -H "Content-Type: application/json" \
  --data '{"type":"'"$TYPE"'","name":"'"$NAME"'","content":"'"$IP"'","proxied":'"$PROXY"'}' >> ${logfile} 2>&1
}