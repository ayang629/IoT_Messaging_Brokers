import paho.mqtt.client as mqtt
import sys

class MQTT_Client:
	def __init__(self, num_msgs, ip_addr):
		self.client = mqtt.Client()
		self.client.on_connect = self.on_connect
		self.client.on_message = self.on_message
		self.num_msgs = num_msgs
		self.client.connect(ip_addr, 1883, 180)
		print "Client connected!"

	def run(self):
		self.client.loop()


	def on_connect(self, client, userdata, rc):
		print("Connected with result code "+str(rc))
		# Subscribing in on_connect() means that if we lose the connection and
		# reconnect then subscriptions will be renewed.
		client.subscribe("$SYS/#")

	# The callback for when a PUBLISH message is received from the server.
	def on_message(self, client, userdata, msg):
		print(msg.topic+" "+str(msg.payload))


if __name__ == "__main__":
	num_msgs = sys.argv[1]
	ip_addr = sys.argv[2]
	client = MQTT_Client(num_msgs, ip_addr)
	client.run()