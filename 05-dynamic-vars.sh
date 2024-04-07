#!/bin/bash

DATE=$(date +%F)

echo -e "Welcome to training today date is \e[31m ${DATE} \e[0m"
echo -e "Current user session in the system are : $(who | wc -l)"