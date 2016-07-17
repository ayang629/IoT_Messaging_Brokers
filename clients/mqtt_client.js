var mqtt    = require('mqtt');
var process = require('process');

//Parsing Arguments
var argv = require('minimist')(process.argv.slice(2));
var clientType = (argv.clientType == null) //Defines whether the clients launched in this process. DEFAULT PUB
				? 'pub'
				: argv.clientType; 
var qos = (argv.q == null) //Defines pub message QoS. DEFAULT 0.
				? 0
				: argv.q;
var host = (argv.h == null) //Defines the host mqtt clients connect to. Default localhost.
				? '127.0.0.1'
				: argv.h;
var port = (argv.p == null) //Defines the port mapping. Defaults to 1883
				? 1883
				: argv.p;
var numMsgs = (argv.m == null) //Defines the number of messages a publisher will publish. Defaults to 100 
				? 100
				: argv.m;
var numTopics = (argv.numTopics == null) //Number of topics that will be mapped (From topicBase --> topicBase+numTopics)
				? 1
				: argv.numTopics; 
var topicBase =  (argv.to == null) //unique topic number base. Defaults to 0  
				? 0
				: argv.to;
var counterOffset = (argv.co == null) //unique sequence number base for messages. Defaults to 0
				? 0
				: argv.co;
var topicInstances = (argv.ti == null) //how many client instances for a given topic are created.
				? 1
				: argv.ti;
var publishInterval = (argv.pi == null) //how often (in ms) you want a publisher to publish a message. Defaults to 100
				? 100
				: argv.ti;

//Arrays and variables that help keep track of multiple client instances launched in this node instance.
var outputIndexArray = []
var counterArray = [];
var clientArray = [];
var clrIntArray = []; //takes setInterval return object to stop calling the interval 
var numClosed = 0;
var totalReceived = 0;
var totalToRecv = parseInt(numMsgs) * parseInt(numTopics) * parseInt(topicInstances);
var topicLimit = topicBase + numTopics;

function create_client(clientArray, i, instance){
	counterArray.push(parseInt(numMsgs));
	var topic = "topic" + i;
	var cid = clientType + "_mqttjs_" + topic + "_" + instance;
	var options = {
	  host: host,
	  port: port,
	  keepalive:600,
	  clientId: cid
	};
	var client  = new mqtt.connect(options);
	clientArray.push(client);

	client.on('message', function (topic, message, packet) {
	  // message is Buffer 
	  var unixtimestamp =  new Date().getTime()
	  var string_msg =  message.toString();
	  totalReceived += 1;
	  console.log('RECV', topic, message.toString(), unixtimestamp);
	  if(totalReceived >= totalToRecv){
	  		console.log("Exiting subscriber process...");
  			client.end();
  			process.exit();
	  }
	});

	client.on('connect', function (options) {
	  	var index = i - topicBase;
	  	if (clientType == "pub"){
	  		var numPublishes = parseInt(numMsgs) / parseInt(topicInstances); //divide numMsgs by the # of topicInstances
	  		console.log("Publisher will publish " + numPublishes + "messages");
	  		counterArray[index] = parseInt(numMsgs);
	  		function publish_async(client){
				if(counterArray[index] <= 0){
					console.log("Finished publishing topic " + topic);
					client.end(true);
					clearInterval(clrIntArray[index]);
					numClosed += 1;
					if (numClosed >= (numTopics * topicInstances)){ //multiply by topicInstances b/c of -ti arg
						console.log("Exiting publishing process...");
						process.exit();
					}
				}else{
					var pidBuffer = new Buffer(process.pid.toString() + " " + (counterOffset++));
					var unixtimestamp =  new Date().getTime();
					client.publish(topic, pidBuffer, {qos:parseInt(qos)});
					console.log('PUB', topic, pidBuffer.toString(), unixtimestamp);
					counterArray[index] -= 1;
				}
	  		};

	  		clrIntArray[index] = setInterval(publish_async, publishInterval, client); //SECOND ARGUMENT CONTROLS PUBLISHING INTERVALS
		}else if(clientType == "sub"){
			setTimeout(function () {
			  console.log('Timing out...');
			  process.exit();
			}, 600000);
			var subTopic = topic;
			var unixtimestamp =  new Date().getTime();
			client.subscribe(subTopic, {qos:parseInt(qos)});
			console.log('SUB', subTopic, unixtimestamp, client.options.clientId);
		}
	});
	return clientArray;
}

//Actually run the code
for(var i = topicBase; i < topicLimit; ++i){
	for(var j = 0; j < topicInstances; ++j){
		create_client(clientArray, i, j);
	}
}

