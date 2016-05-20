#!/bin/bash

#usage: ./processOutput.sh [pubsub | multi] [mosquitto | mosca | ponte] 
#IMPORTANT: DO NOT CHANGE EXPERIMENT.CONF UNTIL YOU'VE RUN THIS SCRIPT TO PROCESS THE OUTPUT

TYPE=$1
BROKER=$2
DATA=`cat experiment.conf | grep -e '^-'`
NUM_TOPICS=`echo "$DATA" | sed -n 2p | awk '{print $2}'`
NUM_MSGS=`echo "$DATA" | sed -n 4p | awk '{print $2}'`
NUM_EXPS=`echo "$DATA" | sed -n 9p | awk '{print $2}'` 
SUBS_PER_TOPIC=`echo "$DATA" | sed -n 5p | awk '{print $2}'`
CLIENTS_PER_PROCESS=`echo "$DATA" | sed -n 10p | awk '{print $2}'` 
for x in $(seq 1 1 "$NUM_EXPS")
do
	# if [[ "$BROKER" == "ponte" ]] || [[ "$BROKER" == "mosca" ]]; then
	# 	echo "Processing server throughput..."
	# 	./processServerThroughput.sh "$TYPE" "$BROKER" "$NUM_TOPICS" "$NUM_MSGS"
	# fi
	if [[ "$TYPE" == "multi" ]]; then
		echo "Processing multipurpose output experiment #${x}..."
		COUNT=`ls -l multiLogs/ | wc | awk '{print $1}'` #number of files in multiLog
		echo "Number topics: $NUM_TOPICS" > "expResults/multiOutput$NUM_TOPICS.txt"
		NUM_FILES=`expr $COUNT - 1`
		FILENAME="multi"
		for i in $(seq 1 1 "$NUM_FILES")
		do
			FILENAME="${FILENAME}${i}.txt"
			cat multiLogs/${FILENAME} >> "expResults/multiOutputTemp$NUM_TOPICS.txt"
			echo $FILENAME
			FILENAME="multi"
		done
		cat "expResults/multiOutputTemp$NUM_TOPICS.txt" |  grep -v "SUB" | grep -v "Timing" | grep -v "Finished" | grep -v "Exiting" | sort -n -k2,2 -k4,4 -k1,1 > "expResults/multiOutput$NUM_TOPICS.txt"
		rm -f "expResults/multiOutputTemp$NUM_TOPICS.txt"
		echo "Running python script..."
		if [ ! -f "expResults/pyGenMulti$NUM_TOPICS.txt" ]; then
			echo "Output file not found"
	    	touch "expResults/pyGenMulti$NUM_TOPICS.txt"
		fi
		python generateGraph.py "expResults/multiOutput$NUM_TOPICS.txt" "$NUM_TOPICS" "$NUM_MSGS" "$SUBS_PER_TOPIC" >> "expResults/pyGenMulti$NUM_TOPICS.txt"
	elif [[ "$TYPE" == "pubsub" ]]; then
		echo "Processing pubsub output into "expResults/pubsubOutput$NUM_TOPICS.txt"..."
		SUB_INT=`ls -l subLogs/ | wc | awk '{print $1}'`
		COUNT_SUB=`expr $SUB_INT - 1` #removes 'total' line from ls -l
		COUNT_SUB=`expr $COUNT_SUB / $NUM_EXPS` #divides experiments 
		PUB_INT=`ls -l pubLogs/ | wc | awk '{print $1}'`
		COUNT_PUB=`expr $PUB_INT - 1` #removes 'total' line from ls -l
		COUNT_PUB=`expr $COUNT_PUB / $NUM_EXPS`
		echo "Number topics: $NUM_TOPICS" > "expResults/pubsubOutputTemp$NUM_TOPICS.txt"
		for i in $(seq 1 1 "$COUNT_SUB") #cat in subLogs files
		do
			echo "subLogs/sub${x}_${i}.txt"
			cat "subLogs/sub${x}_${i}.txt" >> "expResults/pubsubOutputTemp$NUM_TOPICS.txt"
		done
		for i in $(seq 1 1 "$COUNT_PUB") #cat in pubLogs files
		do
			echo "pubLogs/pub${x}_${i}.txt"
			cat "pubLogs/pub${x}_${i}.txt" >> "expResults/pubsubOutputTemp$NUM_TOPICS.txt"
		done
		#sort the files together
		cat "expResults/pubsubOutputTemp$NUM_TOPICS.txt" | grep -v "SUB" | grep -v "Timing" | grep -v "Finished" | grep -v "Exiting" |sort -k4,4n -k2,2 | grep -v "Number topics"  > "expResults/pubsubOutput$NUM_TOPICS.txt"
		rm -f "expResults/pubsubOutputTemp$NUM_TOPICS.txt" #remove intermediate file
		if [ ! -f "expResults/pyGenPubsub$NUM_TOPICS.txt" ]; then #create experiment output file if does not exist
			echo "Output file not found"
	    	touch "expResults/pyGenPubsub$NUM_TOPICS.txt"
		fi
		python generateGraph.py "expResults/pubsubOutput$NUM_TOPICS.txt" "$NUM_TOPICS" "$NUM_MSGS" "$SUBS_PER_TOPIC" >> "expResults/pyGenPubsub$NUM_TOPICS.txt"
	else
		echo "Invalid output options: Legal options are [pubsub | multi]"
	fi

	echo "Processing client throughput..."
	./processClientThroughput.sh "$TYPE" "$BROKER" "$NUM_TOPICS" "$NUM_MSGS" "$NUM_EXPS"

done