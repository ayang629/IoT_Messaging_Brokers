var mqtt    = require('mqtt');
var process = require('process');
var client  = mqtt.connect({ host: process.argv.slice(2)[4], port: 3001 });
 

client.on('connect', function () {
  	var clientType = process.argv.slice(2)[0];
  	var qos = process.argv.slice(2)[1];
  	var topic = process.argv.slice(2)[3];
  	if (clientType == "pub"){
		var numPublishes = parseInt(process.argv.slice(2)[2]);
		var counter = 0;
		while(numPublishes--){ 
		  	var pidBuffer = new Buffer(process.pid.toString() + " " + (counter++));
		  	var unixtimestamp =  new Date().getTime()
  			console.log('PUB', topic, pidBuffer.toString(), unixtimestamp);
		  	client.publish(topic, pidBuffer, {qos:parseInt(qos)});
		}
	}else if(clientType == "sub"){
		var subTopic = topic;
		var unixtimestamp =  new Date().getTime()
		console.log('SUB', subTopic, unixtimestamp)
		client.subscribe(subTopic, {qos:parseInt(qos)});
	}
	else if(clientType == "multi"){
		//First, subscribe to the topic given
		var subTopic = topic;
		var unixtimestamp =  new Date().getTime()
		console.log('SUB', subTopic, unixtimestamp)
		client.subscribe(subTopic, {qos:parseInt(qos)}); //callback publish 
		var numPublishes = parseInt(process.argv.slice(2)[2]);
		var counter = 0;
		while(numPublishes--){ 
		  	var pidBuffer = new Buffer(process.pid.toString()+ " " + (counter++));
		  	var unixtimestamp =  new Date().getTime()
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


