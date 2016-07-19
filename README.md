# IoT_Messaging_Brokers

To come (the to-do list):

	- Kafka/redis-cluster integration

	- increased plug-and-play functionality, including measurement for SCALE data

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

About the available brokers: mosca, mosquitto, and ponte.

	The mosquitto broker is a barebones broker that listens on port 1883 by default.

	The mosca broker uses a mosquitto broker that listens on port 1883. The mosca broker itself listens on port 3001. 

	The ponte broker uses a mosca instance (port 3001) as well as CoAP (3000) and HTTP (port 8080) servers. 

EXPERIMENT WORKFLOW:

	Running an experiment is simple. The basic workflow can be essentialized to 5 steps:

		1.) Configure experiment.conf to set up your experiment

		2.) Launch a server (currently 3 are implemented, NOTE: Ponte may be buggy. This will be updated soon)

		3.) Run experiment_driver.sh, which currently is only implemented with mqttjs. SCALE data to come.

		4.)	Run ./processOutput.sh to get your output in expResults/ 

		5.) Clean your logs with ./cleanLogs.sh 

	Open experiment.conf and read experiment_conf_details.txt to see detailed documentation on how to configure an experiment.

	To run a server:
		
		$ ./servers.sh [mosquitto | mosca | ponte] 

		NOTE: As mentioned, the mosca server needs running mosquitto broker as it uses it for its pubsub capabilities. 

		# ./servers.sh mosquitto

		$ ./servers.sh mosca

	The clients take one of 3 options: simple (bare-mosquitto calls), mqttjs, and paho. 

	CURRENTLY, ONLY THE MQTTJS CLIENT IS CONFIGURED FOR EXPERIMENTS. 

	To run client experiment:

		First, make sure your servers are running. Then, run the following command:

		$ ./experiment.sh experiment.conf

	To run analysis script on experiment results: 

		(IMPORTANT: DO NOT CHANGE THE 1st, 3rd, 4th or 9th ARGUMENTS OF experiment.conf BEFORE YOU RUN THIS):

		(ALSO IMPORTANT: If you choose to to have the experiment run publishers and subscribers on separate machines,
		 make sure the output, located in pubLogs/ and subLogs/ folders respectively, are on the machine you run 
		 ./processOutput.sh on. Make sure the experiment.conf configurations for the aforementioned argument are identical.)

		$ ./processOutput.sh [mosquitto | mosca | ponte] 

	To clean scripts:

		Cleans all files in multiLogs/ pubLogs/ and subLogs/ automatically. Deletes server output file too

		$ ./cleanLogs.sh [mosca | mosquitto | ponte]

Details of output (in expResults directory): 
	
	In Latency file (named 'pyGen[pubsub | multi]Output[num_topics].txt'):

		If the "topic" granularity option (-g) is given, each experiment will give basic topic-level statistics, 
		which include the min, max, and avg RTT as well as the percent received.

		Generally, you will get experiment-level summaries that include the total number and percentage of messages 
		that have successfully been received as well as experiment-level averages of latency (RTT) and jitter.

EXTRA: About the underlying scripts:

	There are two interesting scripts that handle most of the complexity of the experiments: clients/mqtt_client.js and generateOutput.py. They are implemented with specific command line arguments, so below is a brief rundown on how to run them individually:

	For generateOutput.py, type python generateOutput.py --help for a rundown of the arguments and options

	For clients/mqtt_client.js what arguments you want to provide depend on whether you're launching pubs or subs:

		For both:

			--clientType= : pub or sub 

			-q : [0 | 1 | 2]

			-h : IP address

			-p : Port 

			--numTopics= : Number of instances

			--to= : The base number of your topic. Topic names formatted as clientType_mqttjs_topic[topic_offset#]_[instance#]
					(e.g: pub_mqttjs_topic5_1, sub_mqttjs_topic34_12)

			--ti= : The number of instances you want the process to launch per topic.

		For publishers:

			-m : The total number of messages you want published per topic

			--co= : Published messages have an unique publish offset in the context of the experiment. This argument is the
					base number in a range (from --co to --co + -m) that your publishers will label their messages as.

		No unique subscriber arguments are defined.




	





