#!/bin/bash

# Define the log file
log_file="/var/log/named/named.log"
TIMESTAMP_LOG="/root/pingback.log"

# Monitor the log file
tail $log_file | awk '/0x74686564316d70696e676261636b/ {print $2,$10,$16}' | while IFS= read -r line; do
    # Extract field $2 and $10 using awk
    TIME=$(echo "$line" | /usr/bin/awk '{print $1}')
    ID=$(echo "$line" | /usr/bin/awk '{print $1}' | xxd -p | md5sum | awk '{print $1}')
    QUERY=$(echo "$line" | /usr/bin/awk '{print $2}')
    IP=$(echo "$line" | /usr/bin/awk '{print $3}' | sed -e "s/\/.*//g")

    if grep -q "$ID" $TIMESTAMP_LOG
    then
        continue
    else
        echo -e "Pingback hit form \`$IP\` at \`$TIME\`." | /root/go/bin/notify -bulk -silent -id req &> /dev/null
        echo $ID | /root/go/bin/anew $TIMESTAMP_LOG &> /dev/null
    fi
done

