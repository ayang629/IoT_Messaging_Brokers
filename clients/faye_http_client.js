var fs   = require('fs'),
	faye = require('faye');

var client = new faye.Client('http://localhost:8080', {retry: 5});

client.connect();
console.log("client connected");

// var subscription = client.subscribe('foo', function(message) {
//   	console.log("RECEIVED: ", message);
// });

// subscription.then(function() {
//   console.log('Subscription is now active!');
// });

var publication = client.publish('/resources/topic1', {text: 'Hi there'}, {deadline: 5});

  publication.callback(function() {
    console.log('[PUBLISH SUCCEEDED]');
  });
  publication.errback(function(error) {
    console.log('[PUBLISH FAILED]', error);
  });

// publication.then(function() {
//   console.log('Message received by server!');
// }, function(error) {
//   console.log('There was a problem: ' + error.message);
// });