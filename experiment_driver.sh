#!/bin/bash

CLIENT_PIDS=() #need to get shell pids 

trap ctrl_c INT
function ctrl_c() { #Handles shutting down clients
	ARR_INC=${#CLIENT_PIDS[@]}
	echo "killing all client scripts..."
	kill `ps -ef | grep 'mqtt_client.js' | grep -v grep | awk '{print $2}'` #kill all mqtt_client.js instances
	kill `ps -ef | grep 'sleep 180' | grep -v grep | awk '{print $2}'` #kill all sleep 180's
}

#Do defaults if no conf file specified
if [[ "$#" -eq 1 ]]; then
	echo "Running experiment with configuration file: $1 ..."
	CONF=$1
	#get data from configuration file and strip any line that doesn't start with a '-'
	DATA=`cat experiment.conf | grep -e '^-'`

	#Separate configuration options into variables
	EXP_TYPE=`echo "$DATA" | sed -n 1p | awk '{print $2}'`

	NUM_TOPICS=`echo "$DATA" | sed -n 2p | awk '{print $2}'`

	PUBS_PER_TOPIC=`echo "$DATA" | sed -n 3p | awk '{print $2}'`

	MSGS_PER_TOPIC=`echo "$DATA" | sed -n 4p | awk '{print $2}'`

	SUBS_PER_TOPIC=`echo "$DATA" | sed -n 5p | awk '{print $2}'`

	MULTIPURPOSE=`echo "$DATA" | sed -n 6p | awk '{print $2}'`

	CLIENT_TYPE=`echo "$DATA" | sed -n 7p | awk '{print $2}'`

	QOS=`echo "$DATA" | sed -n 8p | awk '{print $2}'`

else
	echo "Running default configuration..."
	EXP_TYPE="throughput"

	NUM_TOPICS=10

	PUBS_PER_TOPIC=1

	MSGS_PER_TOPIC=100

	SUBS_PER_TOPIC=1

	MULTIPURPOSE="no"

	CLIENT_TYPE="mqttjs"

	QOS=1
fi


if [[ "$EXP_TYPE" -eq "throughput" ]]; then
	echo "Running throughput experiment..."
	NUM_SUBS=`expr $NUM_TOPICS / $SUBS_PER_TOPIC`
	TOPIC_NAMES=()
	TOPIC="topic"
	if [[ "$MULTIPURPOSE" -eq "no" ]]; then
		for i in $(seq 1 1 "$NUM_SUBS") #first launch clients that are subscribers
		do
			TOPIC="$TOPIC$i"
			bash clients.sh "$CLIENT_TYPE" sub "$SUBS_PER_TOPIC" "$QOS" "$TOPIC" "$i" &
			CLIENT_PIDS+=($!)
			TOPIC_NAMES+=($TOPIC)
			TOPIC="topic"
		done
		for j in $(seq 0 1 "`expr $NUM_SUBS - 1`") #launch publishers to publish messages to clients
		do
			MSGS_PER_CLIENT=`expr $MSGS_PER_TOPIC / $PUBS_PER_TOPIC`
			bash clients.sh "$CLIENT_TYPE" pub "$PUBS_PER_TOPIC" "$QOS" "$TOPIC" "$MSGS_PER_CLIENT" "$j" &
			CLIENT_PIDS+=($!)
		done
	else
		echo "IMPLEMENT MULTIPURPOSE: Clients are both publishers and subscribers"
	fi
fi

sleep 120



