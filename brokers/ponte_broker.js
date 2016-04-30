var ponte = require("ponte");
var opts = {
  logger: {
    level: 'info'
  },
  http: {
    port: 3000 // tcp 
  },
  mqtt: {
    port: 1883 // tcp 
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
    type: "redis",
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
  console.log("Resource Updated", resource, buffer);
});
 
// Stop the server after 1 minute 
setTimeout(function() {
  server.close(function() {
    console.log("server stopped");
  });
}, 120 * 1000);
