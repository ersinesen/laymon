#!/bin/bash

THRESHOLD=0.1
LOAD=$(uptime | awk -F'load average: ' '{ print $2 }' | cut -d',' -f1)

if (( $(echo "$LOAD > $THRESHOLD" | bc -l) )); then
    echo "CPU load is high: $LOAD" 
    SUBJECT="High CPU Load Alert"
    MESSAGE="CPU load is high: $LOAD"
    TO="ersin.esen@tetrabilisim.com.tr"
    #echo "$MESSAGE" | mail -s "$SUBJECT" "$TO"
    echo -e "Subject: $SUBJECT\n\n$MESSAGE" | msmtp $TO

fi
