#!/bin/sh
#
# script /qmf/qml/apps/xmlHttpRequestHowTo/xmlHttpRequestHowTo.sh
# Create output /tmp/<script-name>.json
#
# to test from command line : 
#   /bin/sh /qmf/qml/apps/xmlHttpRequestHowTo/xmlHttpRequestHowTo.sh test
#
# to activate via tsc :
#   echo external-xmlHttpRequestHowTo >>/tmp/tsc.command
#
output=/tmp/`basename "$0"`.json

# use system profile

. /etc/profile

do_it () {
    UPTIME=$(cut -d "." -f 1 /proc/uptime)
    #
    PID=$(pidof qt-gui)
    STARTTIME=$(( $(cut -d " " -f 22 /proc/$PID/stat) / 100 ))

    FREEMEM=$(grep MemFree /proc/meminfo | tr -s " " | cut -d " " -f 2)

    VmSize=$(echo $(grep /proc/$PID/status -e VmSize) | cut -d " " -f 2)

    json="{"
    json="$json\"toonUptime\" : $UPTIME"
    json="$json , \"guiPID\" : $PID"
    json="$json , \"guiUptime\" : $((UPTIME - STARTTIME))"
    json="$json , \"guiVmSize\" : $VmSize"
    json="$json , \"freeMemory\" : $FREEMEM"
    json="$json}"
    echo $json
}

if [ "$1" == "" ]
then
# use next line when running via tsc
    mecount=$(( $(ps | grep xmlHttpRequestHowTo.sh | grep -v grep | wc | tr -s " " | cut -d" " -f 2) ))
else
# use the next line for testing from command line
    mecount=$(( $(ps | grep xmlHttpRequestHowTo.sh | grep -v grep | wc | tr -s " " | cut -d" " -f 2) -2 ))
fi

if [ $mecount == 0 ]
then
    do_it > $output
    if [ "$1" != "" ]
    then
        cat $output
    fi
else
    exit
fi
