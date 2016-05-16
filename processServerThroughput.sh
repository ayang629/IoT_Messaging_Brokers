#!/bin/bash

#usage: ./processServerThroughput.sh [pubsub | multi] [mosca | ponte] [num_topics] [num_msgs]

CLIENT_TYPE=$1
BROKER=$2
NUM_TOPICS=$3
NUM_MSGS=$4

if [ ! -f "expResults/${BROKER}ServerThroughput.txt" ]; then
	echo "Output file not expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt found"
	touch "expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt"
fi
echo "" >> "expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt" #new line
echo "Running Throughput experiment with ${BROKER} (${NUM_TOPICS} Topics)" >> "expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt"
#print out sorted raw data (uncomment below to show)
#cat serverLogs/mosca_output.txt | grep "CLIENT_PUB" | awk '{print $4}' | sort | uniq -c | sort -nr  >> "expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt"

#print out start_time
START_TIME=`cat serverLogs/mosca_output.txt | grep "CLIENT_PUB" | awk '{print $3}' | sort | head -1`
echo "Start time: ${START_TIME}" >> "expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt"

#print out end time
END_TIME=`cat serverLogs/mosca_output.txt | grep "CLIENT_PUB" | awk '{print $3}' | sort | tail -1`
echo "End time: ${END_TIME}" >> "expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt"

#print out time elapsed
TIME_ELAPSED=`expr $END_TIME - $START_TIME`
echo "Time elapsed: $TIME_ELAPSED" >> "expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt"

#print messages received by broker 
MSGS_RECVD=`cat serverLogs/mosca_output.txt | grep "CLIENT_PUB"| wc | awk '{print $1}'`
echo "Msgs received: $MSGS_RECVD" >> "expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt"

TOTAL_MSGS=`expr $NUM_TOPICS \* $NUM_MSGS`
echo "Total messages sent by clients: $TOTAL_MSGS" >> "expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt"

PERCENT_RECVD=`echo  "scale=2;$MSGS_RECVD/$TOTAL_MSGS*100" | bc -l`
echo "Percent received: ${PERCENT_RECVD}%" >> "expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt"

THROUGHPUT=`echo "scale=2;$MSGS_RECVD/$TIME_ELAPSED*1000" | bc -l`
echo "Throughput (per sec) : $THROUGHPUT" >> "expResults/${BROKER}${NUM_TOPICS}ServerThroughput.txt"