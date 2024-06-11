#!/bin/bash

ENV_FILE="state.env"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi


THRESHOLD=0.2
LOAD=$(uptime | awk -F'load average: ' '{ print $2 }' | cut -d',' -f1)

if (( $(echo "$LOAD > $THRESHOLD" | bc -l) )); then
    echo "CPU load is high: $LOAD" 
    if [ "$ALERT_SENT" = "true" ]; then
        echo "Alert already sent. Exiting."
        exit 0
    fi

    SUBJECT="High CPU Load Alert"
    MESSAGE="CPU load is high: $LOAD"
    TO="ersin.esen@tetrabilisim.com.tr;cengizhan.degirmenci@tetrabilisim.com.tr"
    ATTACHMENT="../web/screenshot.jpg"

    #echo "$MESSAGE" | mail -s "$SUBJECT" "$TO"
    #echo -e "Subject: $SUBJECT\n\n$MESSAGE" | msmtp $TO

    # Create a boundary for the email
    BOUNDARY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

    # Encode the attachment for email
    ATTACH_ENCODED=$(base64 -w 0 $ATTACHMENT)

    # Build the email content
    (
        echo -e "Subject: $SUBJECT"
        echo -e "To: $TO"
        echo -e "Content-Type: multipart/mixed; boundary=\"$BOUNDARY\""
        echo -e "\n--$BOUNDARY"
        echo -e "Content-Type: text/plain; charset=UTF-8"
        echo -e "\n$MESSAGE"
        echo -e "\n--$BOUNDARY"
        echo -e "Content-Type: image/jpeg; name=\"$(basename $ATTACHMENT)\""
        echo -e "Content-Disposition: attachment; filename=\"$(basename $ATTACHMENT)\""
        echo -e "Content-Transfer-Encoding: base64"
        echo -e "\n$ATTACH_ENCODED"
        echo -e "\n--$BOUNDARY--"
    ) | msmtp $TO

    # Set the flag to indicate that the alert has been sent
    ALERT_SENT=true
    echo "ALERT_SENT=$ALERT_SENT" > "$ENV_FILE"

else
    if [ "$ALERT_SENT" = "true" ]; then
        # Reset ALERT_SENT flag
        ALERT_SENT=false
        echo "ALERT_SENT=$ALERT_SENT" > "$ENV_FILE"
        echo "Alert sent state reset."
    fi
fi

