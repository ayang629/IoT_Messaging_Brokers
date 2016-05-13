import sys
import matplotlib
import os
import numpy

class Topic:
	def __init__(self, name, num_msgs, subs_per_topic):
		self.name = name
		self.dict = dict() # keys = counter index, value = [timestamp difference]
		self.missing = set()
		self.total_topic_msgs = num_msgs * subs_per_topic
		self.received = 0
		self.min = 9999999 #begin with a large min
		self.max = 0 #begin with a small max

	def add_entry(self, key, value):
		self.received+=1
		if self.dict.has_key(key):
			self.dict[key].append(value)
		else:
			self.dict[key] = [value]

	def add_missing(self, index):
		self.missing.add(index)

	def get_percentage_received(self):
		return str(float(self.received) / float(self.total_topic_msgs) * 100) + "%"

	def get_average_latency(self):
		return float(numpy.sum(self.dict.values()) / self.received) if self.received != 0 else 0

	def update_minmax(self, difference):
		if(self.min > difference):
			self.min = difference
		if(self.max < difference):
			self.max = difference

	def get_min(self):
		return str(self.min)

	def get_max(self):
		return str(self.max)

	def get_received(self):
		return self.received

def _not_empty(topic_dict):
	filled = 0
	for k, v in topic_dict.items():
		if v.get_received() != 0:
			filled += 1
	return filled

def calculate_statistics(topic_dict, topic_set, order):
	total_avg_delay = 0
	print "topic\tavg(ms)\tmin(ms)\tmax(ms)\tpercent"
	for entry in order:
		v = topic_dict[entry]
		total_avg_delay += v.get_average_latency()
		print "{:7}\t{:6}\t{:6}\t{:6}\t{:6}".format(entry, str(v.get_average_latency()), 
			v.get_min(), v.get_max(),v.get_percentage_received())
	num_empty = _not_empty(topic_dict)
	print "Total Avg delay: " + str(total_avg_delay/num_empty) + " ms"

#XXX
def process_file(lines, line_len, num_msgs, subs_per_topic):
	topic_dict = dict()
	topic_set = set()
	order = []
	index = 1 #first line shows #topics, so start at index 1
	while (index < line_len-subs_per_topic):
		pub_split = lines[index].split(" ")
		topic = pub_split[1]
		received = 0
		for i in range(1, subs_per_topic+1):		
			recv_split = lines[index + i].split(" ")
			if (topic not in topic_set): #check if topic exists already. If not, add to set and add dict entry
				topic_set.add(topic)
				order.append(topic)
				topic_dict[topic] = Topic(topic, num_msgs, subs_per_topic) #change topic to a list XXX
			#if the two entries map together, add the entry information	
			if(pub_split[3] == recv_split[3] and pub_split[0] == "PUB" and recv_split[0] == "RECV"):
				received += 1
				difference = int(recv_split[4]) - int(pub_split[4])
				topic_dict[topic].add_entry(pub_split[3], difference)
				topic_dict[topic].update_minmax(difference)
			else:
				topic_dict[topic].add_missing( (int(pub_split[3])*subs_per_topic) + i) #redefine definition of missing topic entry
				break
		index += (received + 1)
		
	return (topic_dict, topic_set, order)
	

def open_file(filename):
	with open(filename) as f:
		lines = f.readlines()
		return [x.strip() for x in lines]


if __name__ == "__main__":
	# try:
	filename = sys.argv[1]
	num_topics = int(sys.argv[2])
	num_msgs = int(sys.argv[3])
	subs_per_topic = int(sys.argv[4])
	lines = open_file(filename)
	line_len = len(lines)
	if ( line_len-1 != 2*num_topics*num_msgs ): #check if packet loss was detected
		print "Packet Loss: True"
	else:
		print "Packet Loss: False"
	result_tuple = process_file(lines, line_len, num_msgs, subs_per_topic)
	calculate_statistics(result_tuple[0], result_tuple[1], result_tuple[2])
	# except IndexError as e:
	# 	print "Error in main: " + str(e)
	# 	exit(1)