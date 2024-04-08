#!/bin/bash

ACTION=$2

case $ACTION in

start)
    echo "Starting the payment service"
    ;;

stop)
    echo "Stopping the paymet service"
    ;;

Restart)
    echo "Restarting the payment service"
    ;;

*)
    echo "Valid options are Start or Stop or Restart"
    ;;
esac