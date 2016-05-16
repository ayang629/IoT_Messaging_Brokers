var http = require('http'),
    faye = require('faye');

var server = http.createServer(),
    bayeux = new faye.NodeAdapter({mount: '/', timeout: 45});

bayeux.attach(server);
server.listen(8000);
console.log("listening on port 8000");

bayeux.on('handshake', function(clientId) {
  // event listener logic
  console.log("Client connection: " + clientId);
});

bayeux.on('subscribe', function(clientId, channel) {
  // event listener logic
  console.log("Client subscribed: " + clientId);
});

bayeux.on('publish', function(clientId, channel, data) {
  // event listener logic
  console.log("Data received: " + data);
});