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
	NUM_TOPICS=`echo "$DATA" | sed -n 1p | awk '{print $2}'`

	PUBS_PER_TOPIC=`echo "$DATA" | sed -n 2p | awk '{print $2}'`

	MSGS_PER_TOPIC=`echo "$DATA" | sed -n 3p | awk '{print $2}'`

	SUBS_PER_TOPIC=`echo "$DATA" | sed -n 4p | awk '{print $2}'`

	PUBS_PER_PROCESS=`echo "$DATA" | sed -n 5p | awk '{print $2}'` 

	SUBS_PER_PROCESS=`echo "$DATA" | sed -n 6p | awk '{print $2}'`

	CLIENT_TYPE=`echo "$DATA" | sed -n 7p | awk '{print $2}'`

	QOS=`echo "$DATA" | sed -n 8p | awk '{print $2}'`

	EXP_RUNS=`echo "$DATA" | sed -n 9p | awk '{print $2}'` 

	IP_PUB=`echo "$DATA" | sed -n 10p | awk '{print $2}'` 

	PPORT=`echo "$DATA" | sed -n 11p | awk '{print $2}'` 

	IP_SUB=`echo "$DATA" | sed -n 12p | awk '{print $2}'` 

	SPORT=`echo "$DATA" | sed -n 13p | awk '{print $2}'` 

	ISOLATED=`echo "$DATA" | sed -n 14p | awk '{print $2}'` 

	SLEEP=`echo "$DATA" | sed -n 15p | awk '{print $2}'` 

else
	echo "Running default configuration..."
	NUM_TOPICS=50

	PUBS_PER_TOPIC=1

	MSGS_PER_TOPIC=100

	SUBS_PER_TOPIC=1

	PUBS_PER_PROCESS=10

	SUBS_PER_PROCESS=10

	CLIENT_TYPE="mqttjs"

	QOS=1

	EXP_RUNS=1

	IP_PUB="127.0.0.1"

	PPORT=1883

	IP_SUB="127.0.0.1"

	ISOLATED="NO"

	SLEEP=3
fi
#NOTE: Can change options to just directly call the client_type
if [[ "$CLIENT_TYPE" == "mqttjs" ]]; then #Option mqttjs clients
	echo "RUNNING $EXP_RUNS EXPERIMENT(S)"
	for x in $(seq 1 1 $EXP_RUNS) #experiement loop. Run the mqttjs experiment this many times
	do
		echo "Running mqtt experiment $x..."
		if [ "$ISOLATED" == "SUB" ] || [ "$ISOLATED" == "NO" ]; then
			TOFFSET=0 #topic offset
			SUB_LOOPS=`expr $NUM_TOPICS / $SUBS_PER_PROCESS`
			#===============FIRST, HANDLE LAUNCHING THE SUBSCRIBERS==============#
			for i in $(seq 0 1 "`expr $SUB_LOOPS - 1`") #first launch clients that are SUBSCRIBERS
			do
				node clients/mqtt_client.js --clientType=sub -q $QOS -h $IP_SUB -p $SPORT --numTopics=${SUBS_PER_PROCESS} --to=${TOFFSET} --ti=${SUBS_PER_TOPIC} 2>&1 | tee "subLogs/sub${x}_$i.txt" &
				CLIENT_PIDS="$CLIENT_PIDS $!"
				TOFFSET=`expr $TOFFSET + $SUBS_PER_PROCESS`
			done
		fi

		sleep "$SLEEP" #how to configure this sleep time?

		#================NOW HANDLE LAUNCHING THE PUBLISHERS================#
		if [ "$ISOLATED" == "PUB" ] || [ "$ISOLATED" == "NO" ]; then
			PUB_LOOPS=`expr $NUM_TOPICS / $PUBS_PER_PROCESS`
			TOFFSET=0
			OFFSET=0
			MSGS_PER_PROCESS=`expr $MSGS_PER_TOPIC \* $PUBS_PER_PROCESS` #each process will publish msg_per_topic msgs, pubs_per_process times
			for i in $(seq 0 1 "`expr "$PUB_LOOPS" - 1`") #launch publishers to publish messages to clients
			do
				node clients/mqtt_client.js --clientType=pub -q $QOS -h $IP_PUB -p $PPORT --numTopics=${PUBS_PER_PROCESS} -m $MSGS_PER_TOPIC --to=${TOFFSET} --ti=${PUBS_PER_TOPIC} --co=${OFFSET} 2>&1 | tee "pubLogs/pub${x}_$i.txt" &
				CLIENT_PIDS="$CLIENT_PIDS $!"
				OFFSET=`expr $OFFSET + "$MSGS_PER_PROCESS"`
				TOFFSET=`expr $TOFFSET + $PUBS_PER_PROCESS`
			done
		fi
		#================WAIT FOR EVERY CLIENT TO FINISH=================#
		for pid in $CLIENT_PIDS
		do
			wait $pid
			echo "Closed: $pid"
		done
	done
	echo "Finished running $EXP_RUNS experiments. Exiting script..."
	exit 0
else
	echo "Client type: $CLIENT_TYPE not supported yet!..."
	exit 1
fi


