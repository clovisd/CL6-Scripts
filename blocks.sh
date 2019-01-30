#!/bin/bash
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/home/scripts/logs/loader.out 2>&1
#set -x
#set +x(apt-get update -qq) >> ${logfile} & PID=$! 2>&1

(apt-get update) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPDATE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"

(apt-get remove --purge -qq apache2) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[REMOVE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"

(apt-get install -qq nano) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[INSTALL:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"

(apt-get upgrade -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[UPGRADE:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"

(apt-get autoclean -qq) >> ${logfile} & PID=$! 2>&1
    printf  "${GREEN}[AUTOCLEAN:"
while kill -0 $PID 2> /dev/null; do 
    printf  "."
    sleep 3
done
printf "${GREEN}]${NC} - Done\n"

