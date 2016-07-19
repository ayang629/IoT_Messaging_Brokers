#!/bin/bash

#usage: ./processOutput.sh [pubsub | multi] [mosquitto | mosca | ponte] 
#IMPORTANT: DO NOT CHANGE EXPERIMENT.CONF UNTIL YOU'VE RUN THIS SCRIPT TO PROCESS THE OUTPUT

BROKER=$1
DATA=`cat experiment.conf | grep -e '^-'`
#========Gather relevant data from experiment config file to process experiment results...=======#
NUM_TOPICS=`echo "$DATA" | sed -n 1p | awk '{print $2}'`
NUM_MSGS=`echo "$DATA" | sed -n 3p | awk '{print $2}'`
SUBS_PER_TOPIC=`echo "$DATA" | sed -n 4p | awk '{print $2}'`
NUM_EXPS=`echo "$DATA" | sed -n 9p | awk '{print $2}'` 

#========PROCESS EACH EXPERIMENT========#
for x in $(seq 1 1 "$NUM_EXPS")
do
	echo "Processing pubsub output into \"expResults/pubsubOutput$NUM_TOPICS.txt\"..."
	#============Format raw output into a intermediate file===============#
	cat subLogs/sub${x}_*.txt pubLogs/pub${x}_*.txt | grep -E 'RECV|PUB' | sort -n -k4 > "expResults/pubsubOutput$NUM_TOPICS.txt"
	if [ ! -f "expResults/pyGenPubsub$NUM_TOPICS.txt" ]; then #create experiment output file if does not exist
		echo "Creating output file \"expResults/pyGenPubsub$NUM_TOPICS.txt\""
    	touch "expResults/pyGenPubsub$NUM_TOPICS.txt"
	fi
	#=============CALL EXTERNAL PYTHON SCRIPT TO HANDLE CONVERTING FORMATTED OUTPUT INTO STATISTICS================#
	python generateOutput.py -g topic -f "expResults/pubsubOutput$NUM_TOPICS.txt" -t "$NUM_TOPICS" -m "$NUM_MSGS" -s "$SUBS_PER_TOPIC" >> "expResults/pyGenPubsub$NUM_TOPICS.txt"
	#rm -f "expResults/pubsubOutput$NUM_TOPICS.txt" #remove intermediate text document
done