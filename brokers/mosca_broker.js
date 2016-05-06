var mosca = require('mosca'),
    mqtt    = require('mqtt-packet'),
    parser    = mqtt.parser();
var globalCounter = 0;

var database = {
  type: 'redis',
  redis: require('redis'),
  db: 12,
  port: 6379,
  return_buffers: true, // to handle binary payloads
  host: "localhost"
};

var moscaSettings = {
  port: 1883,
  backend: database,
  persistence: {
    factory: mosca.persistence.Redis
  }
};

var server = new mosca.Server(moscaSettings);
server.on('ready', setup);

server.on('clientConnected', function(client) {
    var unixtimestamp =   Math.round(new Date().getTime()/1000);
    console.log('CLIENT_CONN', client.id, client.subscriptions, unixtimestamp);     
});

// fired when a message is received
server.on('published', function(packet, client) {
  var unixtimestamp =   Math.round(new Date().getTime()/1000);
  if((packet.payload) instanceof Buffer){
    console.log("CLIENT_PUB", packet.payload.toString(), (globalCounter++).toString(), unixtimestamp);
  }else{
    console.log("CLIENT_ACTION", packet.topic, packet.payload, unixtimestamp);
  }
});

server.on('subscribed', function(topic, client) {
  var unixtimestamp =   Math.round(new Date().getTime()/1000);
  console.log("CLIENT_SUB", topic, client.id, unixtimestamp);
});

// fired when the mqtt server is ready
function setup() {
  console.log('Mosca server is up and running')
}