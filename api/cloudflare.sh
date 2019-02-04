#!/bin/bash
source base.sh
debug 0
logs cloudflare

function cloudflare $1 $2 $3 $4 $5 $6 {

CFK=$1
CFEMAIL=$2
TYPE=
NAME=
IP=
PROXY=

}


ZONEID2=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE2&status=active" \
  -H "X-Auth-Email: $CFEMAIL" \
  -H "X-Auth-Key: $CFK" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONEID1/dns_records" \
  -H "X-Auth-Email: $CFEMAIL" \
  -H "X-Auth-Key: $CFK" \
  -H "Content-Type: application/json" \
  --data '{"type":"A","name":"'"$DNSRECORD1"'","content":"'"$SERVERIP"'","proxied":false}' >> ${logfile} 2>&1