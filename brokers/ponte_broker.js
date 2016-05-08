var ponte = require("ponte");
var ascoltatori = require('ascoltatori');

var opts = {
  http: {
    port: 3000 // tcp 
  },
  mqtt: {
    port: 3001 // tcp 
  },
  coap: {
    port: 3000 // udp 
  },
  persistence: {
    // same as http://mcollina.github.io/mosca/docs/lib/persistence/redis.js.html
    type: "redis",
    host: "localhost"
  },
  broker: {
    // same as https://github.com/mcollina/ascoltatori#redis
    type: "mqtt",
    port: 1883,
    host: "localhost"
  },
  logger: {
    level: 20,
    name: "Config Test Logger"
  }
};
var server = ponte(opts);
 
server.on("connect", function(client, buffer){
  console.log("Server connected", client, buffer);
});

server.on("updated", function(resource, buffer) {
  var unixtimestamp =   Math.round(new Date().getTime());
  console.log("CLIENT_PUB", resource, buffer.toString(), unixtimestamp);
});
 
// Stop the server after 1 minute 
setTimeout(function() {
  server.close(function() {
    console.log("server stopped");
  });
}, 120 * 1000);
