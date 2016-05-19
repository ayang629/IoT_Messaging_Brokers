var mqtt    = require('mqtt');
var process = require('process');
var sleep = require('sleep');
var options = {
  host: process.argv.slice(2)[4],
  port: 2883,
  keepalive:600
};
var client  = mqtt.connect(options);
var expectedCounter = 0; 


client.on('connect', function () {
  	var clientType = process.argv.slice(2)[0];
  	var qos = process.argv.slice(2)[1];
  	var topic = process.argv.slice(2)[3];
  	var offset = process.argv.slice(2)[5];
  	if (clientType == "pub"){
		var numPublishes = parseInt(process.argv.slice(2)[2]);
		var counter = offset;
		while(numPublishes--){ 
		  	var pidBuffer = new Buffer(process.pid.toString() + " " + (counter++));
		  	var unixtimestamp =  new Date().getTime();
  			console.log('PUB', topic, pidBuffer.toString(), unixtimestamp);
		  	client.publish(topic, pidBuffer, {qos:parseInt(qos)});
		  	sleep.usleep(100000); //SLEEP FOR 100 MS
		}
		console.log("Finished publishing...");
		process.exit();
	}else if(clientType == "sub"){
		setTimeout(function () {
		  console.log('Timing out...');
		  process.exit();
		}, 300000);
		var subTopic = topic;
		var unixtimestamp =  new Date().getTime();
		console.log('SUB', subTopic, unixtimestamp);
		client.subscribe(subTopic, {qos:parseInt(qos)});
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


