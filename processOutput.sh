#!/bin/bash

#usage: ./processOutput.sh [pubsub | multi] [mosquitto | mosca | ponte] [num_topics] [num_msgs]

TYPE=$1
BROKER=$2
NUM_TOPICS=$3
NUM_MSGS=$4

if [[ "$TYPE" == "multi" ]]; then
	echo "Processing multipurpose output..."
	COUNT=`ls -l multiLogs/ | wc | awk '{print $1}'`
	echo "Number topics: $COUNT" > "expResults/multiOutput$NUM_TOPICS.txt"
	NUM_FILES=`expr $COUNT - 1`
	FILENAME="multi"
	for i in $(seq 1 1 "$NUM_FILES")
	do
		FILENAME="${FILENAME}${i}.txt"
		cat multiLogs/${FILENAME} | grep -v "SUB" | sort -k4 -n >> "expResults/multiOutput$NUM_TOPICS.txt"
		echo $FILENAME
		FILENAME="multi"
	done
	echo "Running python script..."
	if [ ! -f "expResults/pyGenMulti$NUM_TOPICS.txt" ]; then
		echo "Output file not found"
    	touch "expResults/pyGenMulti$NUM_TOPICS.txt"
	fi
	python generateGraph.py "expResults/multiOutput$NUM_TOPICS.txt" "$NUM_TOPICS" "$NUM_MSGS" >> "expResults/pyGenMulti$NUM_TOPICS.txt"
elif [[ "$TYPE" == "pubsub" ]]; then
	echo "Processing pubsub output..."
	COUNT=`ls -l subLogs/ | wc | awk '{print $1}'`
	echo "Number topics: $COUNT" > "expResults/pubsubOutput$NUM_TOPICS.txt"
	NUM_FILES=`expr $COUNT - 1`
	for i in $(seq 1 1 "$NUM_FILES")
	do
		cat "subLogs/sub${i}.txt" "pubLogs/pub${i}.txt" | grep -v "SUB" | sort -k4 -n >> "expResults/pubsubOutput$NUM_TOPICS.txt"
	done
	if [ ! -f "expResults/pyGenPubsub$NUM_TOPICS.txt" ]; then
		echo "Output file not found"
    	touch "expResults/pyGenPubsub$NUM_TOPICS.txt"
	fi
	python generateGraph.py "expResults/pubsubOutput$NUM_TOPICS.txt" "$NUM_TOPICS" "$NUM_MSGS" >> "expResults/pyGenPubsub$NUM_TOPICS.txt"
else
	echo "Invalid output options: Legal options are [pubsub | multi]"
fi