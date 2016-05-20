# IoT_Messaging_Brokers

To come (the to-do list):

	- Kafka/redis-cluster integration

	- increased plug-and-play functionality

	- More documentation...

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
		
	other Node-related dependencies are included in the package.json (downloaded into the node_modules folder)

The brokers take one of 3 options: mosca, mosquitto, and ponte.

	The mosquitto broker is a barebones broker that listens on port 1883 by default.

	The mosca broker uses a mosquitto broker that listens on port 1883. The mosca broker itself listens on port 3001. 

	The ponte broker uses a mosca instance (port 3001) as well as CoAP (3000) and HTTP (port 8080) servers. 


To terminate the server, simply provide a SIGINT (ctrl-c) command, which will trigger a trap to clean up background 
processes (e.g: redis persistence server, sleep calls, active node clients).

To run server individually:
	
	$ ./servers.sh [mosquitto | mosca | ponte] 

	NOTE: As mentioned, the mosca server needs running mosquitto broker as it uses it for its pubsub capabilities. 

	# ./servers.sh mosquitto

	$ ./servers.sh mosca

	
The clients take one of 3 options: simple (bare-mosquitto calls), mqttjs, and paho. 

CURRENTLY, ONLY THE MQTTJS CLIENT IS CONFIGURED FOR EXPERIMENTS. 

The num_clients argument determines how many clients the clients.sh script will run at once, and the msgs_per_client represents the number of messages each client will attempt to publish. 

To run client experiment (NOTE, MQTTJS CLIENT SENDS TO PORT 3001 BY DEFAULT, change to 1883 when running pure mosquitto):

	First, make sure your servers are running. Then, run the following command

	$ ./experiment.sh experiment.conf
	
	Options in configuration file:
	
		experiment_type: What type of experiment to run.
		
		num_topics: The number of unique topics to be instantiated.

		publishers_per_topic: How many publishers should be assigned to a given topic.

		msgs_per_topic: How many messages a topic should expect to receive. This number is evenly distributed between clients.

		subscribers_per_topic: The number of clients that will subscribe to a topic

		multipurpose_clients: [yes | no], will tell script to dynamically configure all clients to act as a publisher and a subscriber.

		client_type: Specify what type of client you want to implement

		num_experiments: the number of times you want to run this experiment 

To test different server experiments:

	Pure Mosquitto: (Pure, lightweight MQTT broker)

		$ ./servers.sh mosquitto 

		$ ./experiment_driver.sh [experiment_conf]

	Mosca: (MQTT broker in NodeJS)

		$ ./servers.sh mosquitto 

		$ ./servers.sh mosca

		$ ./experiment_driver.sh [experiment_conf]

	Ponte: (Multiprotocol bridge to handle HTTP and COAP messages)

		$ ./servers.sh ponte

		#OPTIONAL TO OVERLAY SEPARATE MOSCA BROKER 
		$ ./servers.sh mosca #This launches the mosca broker on top of ponte

		$ ./experiment_driver.sh [experiment_conf]

To run analysis script on experiment results:

	$ ./processOutput.sh [pubsub | multi] [mosquitto | mosca | ponte] [num_topics] [num_msgs] [subs_per_topic] [num_exps]

	#If you want to just run the throughput experiment individually:

		$ ./process[Server | Client]Throughput.sh [pubsub | multi] [mosca | ponte] [num_topics] [subs_per_topic] [num_exps]

	Details of output (in expResults directory): 
		
		In Latency file (named 'pyGen[pubsub | multi]Output[num_topics].txt'):

			Packets lost: [True | False]

			"topic avg(ms) min(ms) max(ms) percent_packets_received" --> for each topic

			Total average delay (ms)

		In Server throughput files 

		(named [mosca | ponte][num_topics]ServerThroughput.txt, [mosca | ponte][num_topicsClientThroughput.txt):

			Start time (unix timestamp)

			End time (unix timestamp)

			Time elapsed (in milliseconds): end time - start time

			Messages received: total number of messages received by the broker

			Total messages: total number of messages sent by all the clients in a given experiment (derived from num_topics and subs_per_topic)

			Percentage received: percentage of messages that were received by the broker.

			Throughput: average number of messages that reached the broker per second

To clean scripts:

	Cleans all files in multiLogs/ pubLogs/ and subLogs/ automatically. Deletes server output file too

	$ ./cleanLogs.sh [mosca | mosquitto | ponte]


To launch clients in subgroup:

	$ ./clients.sh [simple | mqttjs] [pub | sub | multi] [num_clients] [QoS] [topic] [num_msgs (ONLY IF PUB chosen)]

	e.g: 

	$ ./clients.sh mqttjs pub 50 2 test_topic 1000 1

	$ ./clients.sh mqttjs sub 25 1 test_topic 1

To launch node client (mqttjs) directly:

	$ node clients/mqtt_client.js [pub | sub] [0 | 1 | 2] [num_msgs_to_publish] [topic_base] [host] [msg_offset] [clients_per_process]

		#num_msgs_to_publish and msg_offset don't matter for sub option 
	





