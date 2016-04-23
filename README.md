# IoT_Messaging_Brokers

To come: 
	script to run installations/configurations
	script to plug in data analysis document

REQUIREMENTS:
	bash
	mosca - 1.*.* (for mosca broker)
	mosquitto - 1.4.8 (for mosquitto server/simple client)
	mqtt - 3.1.1 
	nodejs - 4.2.*
	ponte - 0.0.16 (for ponte broker)
	python - 2.7+ (for paho)
	redis - 3.0.* (for mosca/ponte)
	
To run mosquitto server:
	
	$ mosquitto -c broker_config.conf > data.txt

	(Since mosquitto itself isn't a program, the command must be launched from terminal)

To run 
	
To launch clients:

	$ clients [mosquitto | mosca | ponte] [simple | mqtt] [num_clients] [QoS]

	e.g: 

	$ clients.sh ponte simple 1000 0
	





