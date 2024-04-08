#!/bin/bash

ACTION=$1

case $ACTION in

start)
    echo "Starting the payment service"
    exit 0
    ;;

stop)
    echo "Stopping the paymet service"
    exit 2
    ;;

Restart)
    echo "Restarting the payment service"
    exit 3
    ;;

*)
    echo "Valid options are Start or Stop or Restart"
    exit 4
    ;;
esac