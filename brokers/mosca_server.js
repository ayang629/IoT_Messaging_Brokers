var mosca = require('mosca')
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
    console.log('client connected', client.id);     
});

// fired when a message is received
server.on('published', function(packet, client) {
  var unixtimestamp =   Math.round(new Date().getTime()/1000);
  console.log((globalCounter++).toString(), 'Published', packet.payload, unixtimestamp);
});

// fired when the mqtt server is ready
function setup() {
  console.log('Mosca server is up and running')
}