#!/bin/bash
trap ctrl_c INT
function ctrl_c() { #Handles shutting down redis server
	if [[ "$1" -eq "mosca" ]]; then 
		redis-cli shutdown 
		#just in case things don't behave, below is a command to kill the pid of the redis server
   		# kill $(ps aux | grep 'redis-server' | awk '{print $2}') INT 
    fi
}

case "$1" in
("mosca") #prepare mosca configuration
	echo "Preparing mosca server..."
	redis-server --daemonize yes #run as daemon so server can be executed
	node brokers/mosca_server.js 2>&1 | tee broker_output.txt
;;
("mosquitto") #preparing mosquitto configuration
	echo "Preparing mosquitto server..."
	sleep 10
	#mosquitto -c brokers/broker_config.conf > data.txt
;;
("ponte")
	echo "ERROR: Ponte server not yet implemented!"
	exit 1
;;
*)
	echo "ERROR: $1 is not a legal server option!"
	exit 1
;;
esac
