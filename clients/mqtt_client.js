var mqtt    = require('mqtt');
var client  = mqtt.connect({ host: '192.168.0.10', port: 1883 });
var process = require('process');
 
client.on('connect', function () {
  	var clientType = process.argv.slice(2)[0];
  	console.log(clientType);
  	if (clientType == "pub"){
		client.subscribe('presence');
		var numPublishes = parseInt(process.argv.slice(2)[2]);
		while(numPublishes--){ 
		  	var pidBuffer = new Buffer(process.pid.toString());
		  	client.publish('presence', pidBuffer, {qos:parseInt(process.argv.slice(2)[1])});
		}
		client.end();
	}else{
		console.log("implement sub fxnality");
	}
});

 
client.on('message', function (topic, message) {
  // message is Buffer 
  var unixtimestamp =  Math.round(new Date().getTime()/1000);
  console.log('Published', message.toString(), unixtimestamp);
});