import sys
import os
import itertools
import argparse
import numpy

#The message class contains basic information about a message that was published.
class Message:
	def __init__(self, pub, recv, seq):
		self.pub_time = int(pub)
		self.recv_time = int(recv)
		self.seq_num = int(seq)

	def get_pub_time(self):
		return self.pub_time

	def get_recv_time(self):
		return self.recv_time

	def get_seq_num(self):
		return self.seq_num

	def get_difference(self):
		return self.recv_time - self.pub_time

#The Topic class encapsulates a collection of messages into a convenient data structure
#so that simple measurement calculations can be performed on the captured data.
class Topic:
	def __init__(self, name, num_msgs, subs_per_topic):
		self.name = name
		self.dict = dict() # keys = counter index, value = List of Message Objects
		self.subs_per_topic = subs_per_topic
		self.total_topic_msgs = num_msgs * subs_per_topic
		self.received = 0
		self.min = 9999999 #begin with a large min
		self.max = 0 #begin with a small max

	def add_entry(self, key, pub, recv, seq):
		#If topic message entry doesn't exist, add it in
		if not self.dict.has_key(key): 
			self.dict[key] = [Message(pub, recv, seq)]
			self.received+=1
		#If topic message entry does exist, and it is still expecting more RECV msgs, add it to the key's mapped list
		elif len(self.dict[key]) < self.subs_per_topic:
			self.dict[key].append(Message(pub, recv, seq))
			self.received+=1
		#This should really never happen, but here's an print notifier to say something went wrong
		else:
			print "Something went wrong..."


	def get_percentage_received(self):
		return str(float(self.received) / float(self.total_topic_msgs) * 100) + "%"

	def get_jitter(self, option):
		sorted_msgs = sorted(list(itertools.chain.from_iterable(self.dict.values())), key=lambda x: x.get_difference)
		comp_msgs = sorted_msgs[1:]
		sorted_msgs = sorted_msgs[0:len(sorted_msgs)-1]
		# print "=============="
		# print [a.get_difference() for a in sorted_msgs]
		# print [a.get_difference() for a in comp_msgs]
		# print "=============="
		differences = [float(abs(a.get_difference()-b.get_difference())) for a,b in zip(sorted_msgs, comp_msgs)]
		return float(sum(differences) / len(differences)) if len(differences) > 0 else -1

	def get_average_latency(self, option):
		sum_values = numpy.sum([ msg.get_difference() for msg in list(itertools.chain.from_iterable(self.dict.values())) ])
		if(type(sum_values) is list):
			return float(sum(sum_values) / self.received) if self.received != 0 else 0
		else:
			return float(sum_values/self.received) if self.received != 0 else 0
	
	def update_minmax(self, difference):
		if(self.min > difference):
			self.min = difference
		if(self.max < difference):
			self.max = difference

	def get_min(self):
		return str(self.min)

	def get_max(self):
		return str(self.max)

	def get_min_time(self):
		return min([item for sublist in self.dict.values() for item in sublist])

	def get_max_time(self):
		return max([item for sublist in self.dict.values() for item in sublist])

	def get_received(self):
		return self.received

#Determine whether or not there exists a topic that never received any messages. 
#Helpful so that empty Topics skip the data processing and statistics phase
def _not_empty(topic_dict):
	filled = 0
	for k, v in topic_dict.items():
		if v.get_received() != 0:
			filled += 1
	return filled

#Processes a formatted data file into message and topic data types
def process_file(lines, line_len, num_msgs, subs_per_topic):
	topic_dict = dict()
	latency_dict = dict()
	topic_set = set()
	order = []
	index = 0 #first line shows #topics, so start at index 1
	#For each PUB line
	while (index < line_len):
		pub_split = lines[index].split(" ") #split it up
		topic = pub_split[1] #grab the topic
		seq_num = pub_split[3] #use the unique sequence number to help drive the processing.
		received = 1 #start with line immediately following a PUB

		#check if related topic is in the dictionary yet. If not, add it in
		if (topic not in topic_set): #check if topic exists already. If not, add to set and add dict entry
			topic_set.add(topic)
			order.append(topic)
			topic_dict[topic] = Topic(topic, num_msgs, subs_per_topic) #Topic added here

		#Loop through every possible RECV line that matches the first PUB line
		while(index+received < line_len and lines[index+received].split(" ")[3] == seq_num):		
			recv_split = lines[index + received].split(" ")
			difference = int(recv_split[4]) - int(pub_split[4])
			topic_dict[topic].add_entry(pub_split[3], pub_split[4], recv_split[4], pub_split[3])
			topic_dict[topic].update_minmax(difference)
			received += 1

		#increase the index offset
		index += received 
	return (topic_dict, topic_set, order)

#Handles aggregate calculations for Topic statistics and print out the summary statistics to stdout
def calculate_statistics(topic_dict, topic_set, order, total_msgs, subs_per_topic, gran):
    total_avg_delay = 0
    total_received = 0
    total_jitter = 0
    count_jitter = 0
    if gran == "topic":
    	print "topic\tavg(ms)\tmin(ms)\tmax(ms)\tpercent"
    for entry in order:
            v = topic_dict[entry]
            total_received += topic_dict[entry].get_received()
            total_avg_delay += v.get_average_latency("full")
            intermediate = v.get_jitter("full")
            if (intermediate != -1):
            	count_jitter += 1
            	total_jitter += intermediate
            if gran == "topic":
    			print "{:7}\t{:6}\t{:6}\t{:6}\t{:6}".format(entry, str(v.get_average_latency("full")), v.get_min(), 
    														v.get_max(),v.get_percentage_received())
    num_empty = _not_empty(topic_dict)
    print "Total RECV's received: {:7d} of {:7d} messages".format(total_received, total_msgs*subs_per_topic)
    if ( total_received != total_msgs ): #check if packet loss was detected
            print "Packet Received: {:6.2f}%".format( float((float(total_received) / float(total_msgs*subs_per_topic)) * 100) )
    else:
            print "Packets Received: 100%"
    print "Total Avg delay: " + str(total_avg_delay/num_empty) + " ms"
    print "Total Avg jitter: " + str(total_jitter/count_jitter) + " ms"
	
#opens the data file and returns a list with the stripped data
def open_file(filename):
	with open(filename) as f:
		lines = f.readlines()
		return [x.strip() for x in lines]


if __name__ == "__main__":
	#Parse arguments with argparse
	parser = argparse.ArgumentParser()
	parser.add_argument("-g", help="Give the level of granularity to include or not include individual topic stats")
	parser.add_argument("-f", help="Insert the formatted data file here") 
	parser.add_argument("-t", help="Include the number of topics per experiment", type=int) 
	parser.add_argument("-m", help= "Include the number of messages per topic here", type=int) 
	parser.add_argument("-s", help="Include the number of subscribers attached to each topic here", type=int) 
	args = parser.parse_args()
	#Check if every argument exists
	if not (args.f and args.t and args.m and args.s and args.g):
		print "Must include all arguments. --help to see all arguments (will say 'optional arguments', ignore this)"
		sys.exit(1)

	#populate key variables	
	filename = args.f
	num_topics = args.t
	num_msgs = args.m
	subs_per_topic = args.s
	granularity = args.g
	lines = open_file(filename)
	line_len = len(lines)

	#process file and return a tuple containing the raw data formatted into a python dictionary,
	#set, and a list order to supplement the unordered nature of the dictionary
	result_tuple = process_file(lines, line_len, num_msgs, subs_per_topic)

	#Feed the results of the file into a function that calculates various statistics on the data
	#This function also prints data to stdout. RECOMMENDED TO REDIRECT OUTPUT USING BASH
	calculate_statistics(result_tuple[0], result_tuple[1], result_tuple[2], num_topics*num_msgs, subs_per_topic, granularity)
	print ""
