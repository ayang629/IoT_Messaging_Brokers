import paho.mqtt.client as mqtt
import sys

class MQTT_Client:
	def __init__(self):
		self.client = mqtt.Client()
		self.client.on_connect = self.on_connect
		self.client.on_message = self.on_message
		self.client.connect("localhost", 1883, 60)
		print "Client connected!"

	def run(self):
		self.client.loop()

	# The callback for when the client receives a CONNACK response from the server.
	def on_connect(self, fill, client, userdata, rc):
		print("Connected with result code "+str(rc))
		# Subscribing in on_connect() means that if we lose the connection and
		# reconnect then subscriptions will be renewed.
		client.subscribe("$SYS/#")

	def on_connect(self, client, userdata, rc):
		print("Connected with result code "+str(rc))
		# Subscribing in on_connect() means that if we lose the connection and
		# reconnect then subscriptions will be renewed.
		client.subscribe("$SYS/#")

	# The callback for when a PUBLISH message is received from the server.
	def on_message(self, client, userdata, msg):
		print(msg.topic+" "+str(msg.payload))


if __name__ == "__main__":
	client = MQTT_Client()
	client.run()