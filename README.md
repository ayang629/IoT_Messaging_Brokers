# IoT_Messaging_Brokers

To come

	- script to run installations/configurations on PI's

	- script to plug in data analysis document

REQUIREMENTS:

	bash - >3

	mosca - 1.*.* (for mosca broker; files should be included in node_modules directory)

	mosquitto - 1.4.* (Either go to mosquitto.org or use brew install mosquitto if you have homebrew)

	mqtt - 3.*.* 

	mqttjs - 1.9.* (files should be already included in node_modules directory)

	nodejs - 4.*.* (go to nodejs.org to install)

	ponte - 0.0.16 (for ponte broker; run npm install ponte bunyan -g to install globally)

	python - 2.7+ (for paho)

	redis - 3.*.* (for mosca/ponte; go to redis.io and download the latest stable version)
	
	
The servers take one of 3 options: mosca, mosquitto, and ponte.
The mosca broker will take whatever information it receives and output it into a data file called mosca_output.txt.
The ponte broker will launch brokers and listen for messages from HTTP, MQTT, and COAP and output data into ponte_output.txt
The mosquitto broker will launch and take whatever information it receives and output data into mosquitto_output.txt

To terminate the server, simply provide a SIGINT (ctrl-c) command, which will trigger a trap to clean up the background 
process (i.e: the redis server).

To run server:
	
	$ ./servers.sh [mosquitto | mosca | ponte]

	e.g:

	$ ./servers.sh mosca

	
The clients take one of 3 options: simple (bare-mosquitto calls), mqttjs, and paho. Currently only the mqttjs and simple paho client are implemented. The num_clients argument determines how many clients the clients.sh script will run at once, and the msgs_per_client represents the number of messages each client will attempt to publish. 

To launch clients:

	NOTE: The QoS option, while present, is not functioning yet and may/may not be included in the command line call.
	 	  Regardless, the script will still function.

	$ ./clients.sh [simple | mqttjs] [pub | sub] [num_clients] [QoS] [msgs_per_client]

	   [msgs_per_client argument only needed if pub is given as argument 2]

	e.g: 

	$ ./clients.sh mqttjs pub 50 2 1000 
	$ ./clients.sh mqttjs sub 25 1
	





