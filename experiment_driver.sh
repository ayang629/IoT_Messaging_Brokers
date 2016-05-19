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

	EXP_RUNS=`echo "$DATA" | sed -n 9p | awk '{print $2}'` 

else
	echo "Running default configuration..."
	EXP_TYPE="latency"

	NUM_TOPICS=5

	PUBS_PER_TOPIC=1

	MSGS_PER_TOPIC=1000

	SUBS_PER_TOPIC=1

	MULTIPURPOSE="no"

	CLIENT_TYPE="mqttjs"

	QOS=1
fi
IP_ADDR="128.195.52.93"
#NOTE: Can change options to just directly call the client_type
if [[ "$EXP_TYPE" == "latency" ]]; then #Option throughput: run latency experiment
	for x in $(seq 1 1 $EXP_RUNS)
	do
		echo "Running latency experiment..."
		NUM_SUBS=`expr $NUM_TOPICS \* $SUBS_PER_TOPIC`
		NUM_PUBS=`expr $NUM_TOPICS \* $PUBS_PER_TOPIC`
		TOPIC_NAMES=()
		TOPIC="topic"
		if [[ "$MULTIPURPOSE" == "no" ]]; then
			OFFSET=0
			for i in $(seq 0 1 "`expr $NUM_TOPICS - 1`") #first launch clients that are subscribers
			do
				TOPIC="$TOPIC$i"
				for j in $(seq 1 1 "$SUBS_PER_TOPIC")
				do
					NUM_BASE=$(expr $SUBS_PER_TOPIC \* $i)
					NUM_INC=$(expr $NUM_BASE + $j)
					echo "subLogs/sub${x}_$NUM_INC.txt"
					node clients/mqtt_client.js sub "$QOS" 0 "$TOPIC" "$IP_ADDR" "$OFFSET" 2>&1 | tee "subLogs/sub${x}_$NUM_INC.txt" &
					CLIENT_PIDS="$CLIENT_PIDS $!"
				done
				TOPIC_NAMES+=($TOPIC)
				TOPIC="topic"
			done
			for i in $(seq 0 1 "`expr $NUM_TOPICS - 1`") #launch publishers to publish messages to clients
			do
				OFFSET=0
				MSGS_PER_CLIENT=`expr $MSGS_PER_TOPIC / $PUBS_PER_TOPIC`
				TOPIC="$TOPIC$i"
				for j in $(seq 1 1 "$PUBS_PER_TOPIC")
				do
					NUM_BASE=$(expr $PUBS_PER_TOPIC \* $i)
					NUM_INC=$(expr $NUM_BASE + $j)
					echo "pubLogs/pub${x}_$NUM_INC.txt"
					node clients/mqtt_client.js pub "$QOS" "$MSGS_PER_CLIENT" "$TOPIC" "$IP_ADDR" "$OFFSET" 2>&1 | tee "pubLogs/pub${x}_$NUM_INC.txt" &
					CLIENT_PIDS="$CLIENT_PIDS $!"
					OFFSET=`expr $OFFSET + "$MSGS_PER_CLIENT"`
				done
				TOPIC_NAMES+=($TOPIC)
				TOPIC="topic"
			done
			for pid in $CLIENT_PIDS
			do
				wait $pid
				echo "Closed: $pid"
			done
		else
			#MULTIPURPORSE SINGLE-SCRIPT NOT IMPLEMENTED YET
			for i in $(seq 0 1 "`expr $NUM_TOPICS - 1`") #Launch the clients with a multipurpose configuration
			do
				TOPIC="$TOPIC$i"
				MSGS_PER_CLIENT=`expr $MSGS_PER_TOPIC / $PUBS_PER_TOPIC`
				bash clients.sh "$CLIENT_TYPE" multi "$SUBS_PER_TOPIC" "$QOS" "$TOPIC" "$MSGS_PER_CLIENT" "$i" &
				CLIENT_PIDS+=($!)
				TOPIC_NAMES+=($TOPIC)
				TOPIC="topic"
			done
			sleep 180
		fi
	done
	echo "Finished running $EXP_RUNS experiments. Exiting script..."
	exit 0
elif [[ "$EXP_TYPE" == "throughput" ]]; then
	echo "Running throughput experiment..."
fi

echo "killing all client scripts..."
kill `ps -ef | grep 'mqtt_client.js' | grep -v grep | awk '{print $2}'` #kill all mqtt_client.js instances
kill `ps -ef | grep 'sleep 180' | grep -v grep | awk '{print $2}'` #kill all sleep 180's


