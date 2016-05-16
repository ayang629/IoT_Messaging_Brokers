var http = require('http'),
	fs   = require('fs'),
	process = require('process');

var topicName = process.argv.slice(2)[2];
var numMessages = process.argv.slice(2)[3];
var topicPath = '/resources/'+ topicName;

//set client sending option to command-line specified host and port
var options = {
  host: process.argv.slice(2)[0], // host is first argument 
  port: process.argv.slice(2)[1], // port second argument
  path: topicPath,
  method: 'PUT'
};

//loop through numMessags PUT requestions
var counter = 0;
var data = "";
while (numMessages--){
	var req = http.request(options, function(res) {
	  console.log('STATUS: ' + res.statusCode);
	  console.log('HEADERS: ' + JSON.stringify(res.headers));
	  res.setEncoding('utf8');
	  res.on('data', function (chunk) {
	  	var unixtimestamp =  new Date().getTime();
	  	var data = 'PUB '+  counter + " "  + unixtimestamp + '\n';
	    console.log(data);
	  });
	});

	req.on('error', function(e) {
	  console.log('problem with request: ' + e.message);
	});

	// write data to request body
	req.write(data);
	req.end();
}
