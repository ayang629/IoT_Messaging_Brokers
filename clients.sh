#!/bin/bash
CLIENT_PIDS=()
ARR_INC=`expr $3 - 1`
CLIENT=$1
CLIENT_TYPE=$2
NUM_CLIENTS=$3
QOS=$4
TOPIC=$5
NUM_MSGS=0
FILE_INC=0

if [[ "$CLIENT_TYPE" == "pub" ]]; then
	NUM_MSGS=$6
	FILE_INC=$7
elif [[ "$CLIENT_TYPE" == "sub" ]]; then
	FILE_INC=$6
elif [[ "$CLIENT_TYPE" == "multi" ]]; then
	NUM_MSGS=$6
	FILE_INC=$7
fi

trap ctrl_c INT
function ctrl_c() { #Handles shutting down clients
	for i in $(seq 0 1 "$ARR_INC")
	do
		echo "killing ${CLIENT_PIDS[$i]}"
		kill ${CLIENT_PIDS[$i]}
	done
}	

IP_ADDR=`ifconfig | sed -n 12p | awk '{print $2}'`
case "$CLIENT" in
("simple") #launch daemon 
	echo "Launching $NUM_CLIENTS simple clients..."
	for i in $(seq 1 1 "$NUM_CLIENTS")
	do
		python clients/simple_client.py "$NUM_MSGS" "$IP_ADDR" &
		CLIENT_PIDS+=($!)
	done
	#echo "All clients launched. Script will sleep for 180 seconds."
	#echo "Kill actively running processes with ctrl-c. If scripts completed, kill errors will come up. This is expected"
	sleep 180 #have client script hang so longer running clients can 
;;
("mqttjs") #launch daemon mqttjs clients
	echo "Launching $NUM_CLIENTS mqttjs clients"
	for i in $(seq 1 1 "$NUM_CLIENTS")
	do
		NUM_BASE=$(expr $FILE_INC \* $i)
		NUM_INC=$(expr $NUM_BASE + $i)
		if [[ "$CLIENT_TYPE" == "pub" ]]; then
			echo "Launching publisher..."
			node clients/mqtt_client.js "$CLIENT_TYPE" "$QOS" "$NUM_MSGS" "$TOPIC" "$IP_ADDR" 2>&1 | tee "pubLogs/$CLIENT_TYPE$NUM_INC.txt" &
		elif [[ "$CLIENT_TYPE" == "sub" ]]; then
			echo "Launching subscriber..."
			node clients/mqtt_client.js "$CLIENT_TYPE" "$QOS" "$NUM_MSGS" "$TOPIC" "$IP_ADDR" 2>&1 | tee "subLogs/$CLIENT_TYPE$NUM_INC.txt" &
		elif [[ "$CLIENT_TYPE" == "multi" ]]; then
			echo "Launching multipurpose..."
			node clients/mqtt_client.js "$CLIENT_TYPE" "$QOS" "$NUM_MSGS" "$TOPIC" "$IP_ADDR" 2>&1 | tee "multiLogs/$CLIENT_TYPE$NUM_INC.txt" &
		fi	
		CLIENT_PIDS+=($!)
	done		
	#echo "All clients launched. Script will sleep for 180 seconds."
	#echo "Kill actively running processes with ctrl-c. If scripts completed, kill errors will come up. This is expected"
	sleep 180
;;
*)
	echo "ERROR: $CLIENT is not a legal client option!"
	exit 1
;;
esac