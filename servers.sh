trap ctrl_c INT
function ctrl_c() { #Handles shutting down redis server
	if [[ "$1" -eq "mosca" ]]; then
		redis-cli shutdown 
		#just in case things don't behave, below is a command to kill the pid of the redis server
   		# kill $(ps aux | grep 'redis-server' | awk '{print $2}') INT 
    elif [[ "$1" -eq "ponte" ]]; then
    	redis-cli shutdown 
    fi
}

case "$1" in
("mosca") #prepare mosca configuration
	echo "Preparing mosca broker..."
	redis-server --daemonize yes #run as daemon so broker can be executed
	node brokers/mosca_broker.js 2>&1 | tee serverLogs/mosca_output.txt
;;
("mosquitto") #preparing mosquitto configuration
	echo "Preparing mosquitto broker..."
	/usr/local/sbin/mosquitto -c brokers/broker_config.conf 2>&1 | tee serverLogs/mosquitto_output.txt
;;
("ponte")
	echo "Preparing ponte broker..."
	redis-server --daemonize yes #run as daemon so broker can be executed
	node brokers/ponte_broker.js 2>&1 | tee serverLogs/ponte_output.txt
;;
*)
	echo "ERROR: $1 is not a legal broker option!"
	exit 1
;;
esac
