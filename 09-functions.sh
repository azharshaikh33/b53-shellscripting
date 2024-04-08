#!/bin/bash

# Functions are nothing but a set of command.

sample () {
    echo "I am a message called from sample function"
}
sample

sample
sample
sample

stat () {
    echo -e "\t Total number os session: $(who | wc -l)"
    echo "Today date is $(date +%F)"
    echo "Load average of the system is $(uptime | awk -F : '{print $NF}' | awk -F , '{print $1}')"
    echo "stat function completed"

    echo calling another function
    sample
}

echo calling stat function
stat