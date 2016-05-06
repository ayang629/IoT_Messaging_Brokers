var mqtt    = require('mqtt');
var process = require('process');
var client  = mqtt.connect({ host: process.argv.slice(2)[4], port: 1883 });
 
client.on('connect', function () {
  	var clientType = process.argv.slice(2)[0];
  	var qos = process.argv.slice(2)[1];
  	var topic = process.argv.slice(2)[3];
  	if (clientType == "pub"){
		var numPublishes = parseInt(process.argv.slice(2)[2]);
		while(numPublishes--){ 
		  	var pidBuffer = new Buffer(process.pid.toString());
		  	var unixtimestamp =  Math.round(new Date().getTime()/1000);
  			console.log('PUB', topic, pidBuffer.toString(), unixtimestamp);
		  	client.publish(topic, pidBuffer, {qos:parseInt(qos)});
		}
	}else if(clientType == "sub"){
		var subTopic = topic;
		var unixtimestamp =  Math.round(new Date().getTime()/1000);
		console.log('SUB', subTopic, unixtimestamp)
		client.subscribe(subTopic, {qos:parseInt(qos)});
	}
});

 
client.on('message', function (topic, message, packet) {
  // message is Buffer 
  var unixtimestamp =  Math.round(new Date().getTime()/1000);
  console.log('RECV', message.toString(), unixtimestamp);
});
