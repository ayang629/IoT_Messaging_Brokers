var mqtt    = require('mqtt');
var client  = mqtt.connect({ host: '192.168.0.10', port: 1883 });
var numPublishes = parseInt(process.argv.slice(2));
 
client.on('connect', function () {
  client.subscribe('presence');
  while(numPublishes--){
  	var randMsg = Math.floor(Math.random() * 10000000) + 1;  
  	client.publish('presence', randMsg.toString(), {qos:2});
  }
  client.end();
});
 
client.on('message', function (topic, message) {
  // message is Buffer 
  console.log(message.toString());
  client.end();
});