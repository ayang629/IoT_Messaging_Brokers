#!/bin/bash

#usage: ./processClientThroughput.sh [pubsub | multi] [mosca | ponte] [num_topics] [num_msgs]

CLIENT_TYPE=$1
BROKER=$2
NUM_TOPICS=$3
NUM_MSGS=$4
NUM_EXPS=$5
if [ ! -f "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt" ]; then
	echo "Output file expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt not found"
	touch "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt"
fi

FILENAME="expResults/${CLIENT_TYPE}Output${NUM_TOPICS}.txt"
echo "Running Throughput experiment with ${BROKER} (${NUM_TOPICS} Topics)" >> "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt"
#print out sorted raw data (uncomment below to show)
#cat $FILENAME | grep "CLIENT_PUB" | awk '{print $5}' | sort | uniq -c | sort -nr  >> "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt"

#print out start_time
START_TIME=`cat $FILENAME | grep "RECV" | awk '{print $5}' | sort | head -1`
echo "Start time: ${START_TIME}" >> "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt"

#print out end time
END_TIME=`cat $FILENAME | grep "RECV" | awk '{print $5}' | sort | tail -1`
echo "End time: ${END_TIME}" >> "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt"

#print out time elapsed
TIME_ELAPSED=`expr $END_TIME - $START_TIME`
echo "Time elapsed: $TIME_ELAPSED" >> "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt"

#print messages received by broker 
MSGS_RECVD=`cat $FILENAME | grep "RECV"| wc | awk '{print $1}'`
echo "Msgs received: $MSGS_RECVD" >> "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt"

TOTAL_MSGS=`expr $NUM_TOPICS \* $NUM_MSGS \* $NUM_EXPS`
echo "Total messages sent by clients: $TOTAL_MSGS" >> "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt"

PERCENT_RECVD=`echo  "scale=2;$MSGS_RECVD/$TOTAL_MSGS*100" | bc -l`
echo "Percent received: ${PERCENT_RECVD}%" >> "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt"

THROUGHPUT=`echo "scale=2;$MSGS_RECVD/$TIME_ELAPSED*1000" | bc -l`
echo "Throughput (per sec) : $THROUGHPUT" >> "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt"
echo "" >> "expResults/${BROKER}${NUM_TOPICS}ClientThroughput.txt" #new line