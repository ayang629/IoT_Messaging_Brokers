var mqtt    = require('mqtt');
var process = require('process');
var numTopics = parseInt(process.argv.slice(2)[6]);
var topicBase = parseInt(process.argv.slice(2)[3]);
var topicLimit = topicBase + numTopics;
var lastFlag = false;
function sleep(ms){
    var start = new Date().getTime(), expire = start + ms;
    while(new Date().getTime() < expire){ }
    return;
}

function publish_async(clientType, qos, offset, numPublishes){
	
}

function create_client(client_array, i){
	var topic = "topic" + i;
	var options = {
	  host: process.argv.slice(2)[4],
	  port: 2883,
	  keepalive:600,
	  clientId: "mqttjs_" + topic
	};
	var client  = new mqtt.connect(options);
	client_array.push(client);

	client.on('connect', function (options) {
	  	var clientType = process.argv.slice(2)[0];
	  	var qos = process.argv.slice(2)[1];
	  	var offset = process.argv.slice(2)[5];
	  	if (clientType == "pub"){
			var numPublishes = parseInt(process.argv.slice(2)[2]);
			var counter = offset;
			while(numPublishes--){ 
			  	var pidBuffer = new Buffer(process.pid.toString() + " " + (counter++));
			  	var unixtimestamp =  new Date().getTime();
	  			console.log('PUB', topic, pidBuffer.toString(), unixtimestamp);
			  	client.publish(topic, pidBuffer, {qos:parseInt(qos)});
			  	sleep(100); //SLEEP FOR 100 MS
			}
			console.log("Finished publishing...");
			client.end();
		}else if(clientType == "sub"){
			setTimeout(function () {
			  console.log('Timing out...');
			  process.exit();
			}, 300000);
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
	 
	client.on('message', function (topic, message, packet) {
	  // message is Buffer 
	  var unixtimestamp =  new Date().getTime()
	  console.log('RECV', topic, message.toString(), unixtimestamp);
	});
	return client_array;
}

client_array = [];
//console.log("TOPICBASE: " + topicBase + ", TO: " + topicLimit);
for(var i = topicBase; i < topicLimit; ++i){
	console.log("test");
	client_array = create_client(client_array, i);
}
// while(!lastFlag){

// }
// process.exit();
