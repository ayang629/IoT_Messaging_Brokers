var mqtt    = require('mqtt');
var process = require('process');
var clientType = process.argv.slice(2)[0];
var numTopics = parseInt(process.argv.slice(2)[6]);
var topicBase = parseInt(process.argv.slice(2)[3]);
var topicLimit = topicBase + numTopics;
var outputIndexArray = []
var counterArray = [];
var clientArray = [];
var clrIntArray = []; //takes setInterval return object to stop calling the interval 
var numClosed = 0;

function sleep(ms){
    var start = new Date().getTime(), expire = start + ms;
    while(new Date().getTime() < expire){ }
    return;
}

function create_client(clientArray, i){
	counterArray.push(parseInt(process.argv.slice(2)[2]));
	var topic = "topic" + i;
	var options = {
	  host: process.argv.slice(2)[4],
	  port: 2883,
	  keepalive:600,
	  clientId: clientType + "_mqttjs_" + topic
	};
	var client  = new mqtt.connect(options);
	clientArray.push(client);

	client.on('message', function (topic, message, packet) {
	  // message is Buffer 
	  var unixtimestamp =  new Date().getTime()
	  console.log('RECV', topic, message.toString(), unixtimestamp);
	});

	client.on('connect', function (options) {
	  	var qos = process.argv.slice(2)[1];
	  	var index = i - topicBase;
	  	outputIndexArray[index] = (parseInt(process.argv.slice(2)[5]) * index); //indexing messages so they're unique
	  	if (clientType == "pub"){
	  		var numPublishes = parseInt(process.argv.slice(2)[2]);
	  		counterArray[index] = numPublishes;
	  		function publish_async(client){
				if(counterArray[index] <= 0){
					console.log("Finished publishing topic " + topic);
					client.end(true);
					clearInterval(clrIntArray[index]);
					numClosed += 1;
					if (numClosed >= numTopics){
						console.log("Exiting process...");
						process.exit();
					}
				}else{
					var pidBuffer = new Buffer(process.pid.toString() + " " + (outputIndexArray[index]++));
					var unixtimestamp =  new Date().getTime();
					client.publish(topic, pidBuffer, {qos:parseInt(qos)});
					console.log('PUB', topic, pidBuffer.toString(), unixtimestamp);
					counterArray[index] -= 1;
				}
	  		};

	  		clrIntArray[index] = setInterval(publish_async, 100, client);
			// console.log("Test: " + i);
		}else if(clientType == "sub"){
			setTimeout(function () {
			  console.log('Timing out...');
			  process.exit();
			}, 30000);
			var subTopic = topic;
			var unixtimestamp =  new Date().getTime();
			client.subscribe(subTopic, {qos:parseInt(qos)});
			console.log('SUB', subTopic, unixtimestamp, client.options.clientId);
		}
		else if(clientType == "multi"){
			//First, subscribe to the topic given
			var subTopic = topic;
			var unixtimestamp =  new Date().getTime();
			console.log('SUB', subTopic, unixtimestamp);
			client.subscribe(subTopic, {qos:parseInt(qos)}); //callback publish 
			var numPublishes = parseInt(process.argv.slice(2)[2]);
			var counter = offset;
			while(numPublishes--){ 
			  	var pidBuffer = new Buffer(process.pid.toString()+ " " + (counter++));
			  	var unixtimestamp =  new Date().getTime();
	  			console.log('PUB', topic, pidBuffer.toString(), unixtimestamp);
			  	client.publish(topic, pidBuffer, {qos:parseInt(qos)});
			}
		}
	});
	return clientArray;
}


//console.log("TOPICBASE: " + topicBase + ", TO: " + topicLimit);
for(var i = topicBase; i < topicLimit; ++i){
	create_client(clientArray, i);
}

