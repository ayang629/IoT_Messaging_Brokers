#!/bin/bash
CLIENT_PIDS=()
ARR_INC=`expr $2 - 1`
trap ctrl_c INT
function ctrl_c() { #Handles shutting down clients
	for i in $(seq 0 1 "$ARR_INC")
	do
		echo "killing ${CLIENT_PIDS[$i]}"
		kill ${CLIENT_PIDS[$i]}
	done
}	

case "$1" in
("simple") #prepare mosca configuration
	echo "Launching $2 simple clients..."
;;
("mqttjs") #preparing mosquitto configuration
	echo "Launching $2 mqttjs clients"
	for i in $(seq 1 1 "$2")
	do
		node clients/mqtt_client.js "$3" &
		CLIENT_PIDS+=($!)
	done
	sleep 180
	#mosquitto -c brokers/broker_config.conf > data.txt
;;
*)
	echo "ERROR: $1 is not a legal server option!"
	exit 1
;;
esac