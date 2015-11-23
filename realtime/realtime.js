var app = require('http').createServer(handler);
var server = app.listen(5001);
var io = require('socket.io').listen(server);
var fs = require('fs');
var redis = require('redis').createClient();

function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading index.html');
    }

    res.writeHead(200);
    res.end(data);
  });
}

redis.subscribe('events');

io.on('connection', function(socket){
  console.log(socket.id + ' connected');
  redis.on('message', function(channel, message){
    msg = JSON.parse(message);
    console.log('got message from reids for ' + msg.id_to)
    io.to(msg.id_to).emit('event', message); 
    //io.sockets.socket(msg.id_to).emit('event', message); 
  });
});
