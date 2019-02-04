#!/bin/bash
source base.sh
debug 0

LOGBASE="/opt/cl6/logs"

function_logs () {

if [ $1 = formatting ]; then
    $slug="/" + "&1" + ".log"
    $logfile="$logbase" + "/$slug"
elif [ $1 = art ]; then
    $logfile="$logbase" + "/$slug"
elif [ $1 = blocks ]; then
    $logfile="$logbase" + "/$slug"
elif [ $1 = menu ]; then
    $logfile="$logbase" + "/$slug"
elif [ $1 = menu ]; then
    $logfile="$logbase" + "/$slug"
elif [ $1 = menu ]; then
    $logfile="$logbase" + "/$slug"
else
    $logfile="$logbase" + "/unknown"
fi
}