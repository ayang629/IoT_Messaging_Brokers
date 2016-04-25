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
	
To run server:
	
	$ servers.sh [mosquitto | mosca | ponte]

	e.g:

	$ servers.sh mosca

	
To launch clients:

	$ clients.sh [simple | mqttjs] [num_clients] [msgs_per_client] [QoS]

	e.g: 

	$ clients.sh ponte simple 1000 0
	





