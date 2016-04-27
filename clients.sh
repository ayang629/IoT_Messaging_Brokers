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
("simple") #launch daemon 
	echo "Launching $2 simple clients..."
	for i in $(seq 1 1 "$2")
	do
		python clients/simple_client.py "$3" &
		CLIENT_PIDS+=($!)
	done
	echo "All clients launched. Script will sleep for 180 seconds."
	echo "Kill actively running processes with ctrl-c. If scripts completed, kill errors will come up. This is expected"
	sleep 180 #have client script hang so longer running clients can 
;;
("mqttjs") #launch daemon mqttjs clients
	echo "Launching $2 mqttjs clients"
	for i in $(seq 1 1 "$2")
	do
		node clients/mqtt_client.js "$3" &
		CLIENT_PIDS+=($!)
	done
	echo "All clients launched. Script will sleep for 180 seconds."
	echo "Kill actively running processes with ctrl-c. If scripts completed, kill errors will come up. This is expected"
	sleep 180
	#mosquitto -c brokers/broker_config.conf > data.txt
;;
*)
	echo "ERROR: $1 is not a legal client option!"
	exit 1
;;
esac