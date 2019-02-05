#!/bin/bash
source base.sh
debug 0
logs certbot

function cert-add {

URL="$1"
URLW="www." + "$URL"

certbot run \
	-m ssl@cl6web.com \
	--agree-tos \
	--no-eff-email \
	--redirect \
	-a webroot \
	-i apache \
	-w /opt/cl6/hosting/$URL/html \
	-d $URL \
	-d $URLW \
	>> ${logfile} 2>&1

}
