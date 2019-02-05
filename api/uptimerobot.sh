#!/bin/bash
source base.sh
debug 0
logs uptimerobot

function uprobo-add {

$URL=$1
$API=$2
$TYPE=$3
$NAME=$4


curl -X POST -H "Cache-Control: no-cache" -H "Content-Type: application/x-www-form-urlencoded" -d 'api_key=$API&format=json&type=$TYPE&url=$URL&friendly_name=$NAME' "https://api.uptimerobot.com/v2/newMonitor"                             

}