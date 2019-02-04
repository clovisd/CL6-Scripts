#!/bin/bash
source base.sh
debug 0
logs blocks


function block $1 $2 {
	(apt-get $1 $2) >> ${logfile} & PID=$! 2>&1
	printf  "${GREEN}[$1:"
	while kill -0 $PID 2> /dev/null; do 
		printf  "."
		sleep 3
	done
	printf "${GREEN}]${NC} - Done\n"
}

# (apt-get update) >> ${logfile} & PID=$! 2>&1
    # printf  "${GREEN}[UPDATE:"
# while kill -0 $PID 2> /dev/null; do 
    # printf  "."
    # sleep 3
# done
# printf "${GREEN}]${NC} - Done\n"

# (apt-get upgrade -qq) >> ${logfile} & PID=$! 2>&1
    # printf  "${GREEN}[UPGRADE:\n"
# while kill -0 $PID 2> /dev/null; do 
    # printf  "."
    # sleep 3
# done
# printf "${GREEN}]${NC} - Done\n"

# (apt-get autoremove -qq) >> ${logfile} & PID=$! 2>&1
    # printf  "${GREEN}[AUTOREMOVE:"
# while kill -0 $PID 2> /dev/null; do 
    # printf  "."
    # sleep 3
# done
# printf "${GREEN}]${NC} - Done\n"

# (apt-get autoclean -qq) >> ${logfile} & PID=$! 2>&1
    # printf  "${GREEN}[AUTOCLEAN:"
# while kill -0 $PID 2> /dev/null; do 
    # printf  "."
    # sleep 3
# done
# printf "${GREEN}]${NC} - Done\n"

# (apt-get remove --purge -qq apache2) >> ${logfile} & PID=$! 2>&1
    # printf  "${GREEN}[REMOVE:"
# while kill -0 $PID 2> /dev/null; do 
    # printf  "."
    # sleep 3
# done
# printf "${GREEN}]${NC} - Done\n"

# (apt-get install -qq nano) >> ${logfile} & PID=$! 2>&1
    # printf  "${GREEN}[INSTALL:\n"
# while kill -0 $PID 2> /dev/null; do 
    # printf  "."
    # sleep 3
# done
# printf "${GREEN}]${NC} - Done\n"