#!/bin/bash
CLIENT_PIDS=()
ARR_INC=`expr $3 - 1`
CLIENT=$1
CLIENT_TYPE=$2
NUM_CLIENTS=$3
QOS=$4
NUM_MSGS=$5

trap ctrl_c INT
function ctrl_c() { #Handles shutting down clients
	for i in $(seq 0 1 "$ARR_INC")
	do
		echo "killing ${CLIENT_PIDS[$i]}"
		kill ${CLIENT_PIDS[$i]}
	done
}	

case "$CLIENT" in
("simple") #launch daemon 
	echo "Launching $NUM_CLIENTS simple clients..."
	for i in $(seq 1 1 "$NUM_CLIENTS")
	do
		python clients/simple_client.py "$NUM_MSGS" &
		CLIENT_PIDS+=($!)
	done
	echo "All clients launched. Script will sleep for 180 seconds."
	echo "Kill actively running processes with ctrl-c. If scripts completed, kill errors will come up. This is expected"
	sleep 180 #have client script hang so longer running clients can 
;;
("mqttjs") #launch daemon mqttjs clients
	echo "Launching $NUM_CLIENTS mqttjs clients"
	for i in $(seq 1 1 "$NUM_CLIENTS")
	do
		node clients/mqtt_client.js "$CLIENT_TYPE" "$QOS" "$NUM_MSGS" &
		CLIENT_PIDS+=($!)
	done
	echo "All clients launched. Script will sleep for 180 seconds."
	echo "Kill actively running processes with ctrl-c. If scripts completed, kill errors will come up. This is expected"
	sleep 180
;;
*)
	echo "ERROR: $CLIENT is not a legal client option!"
	exit 1
;;
esac