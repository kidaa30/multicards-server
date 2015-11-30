var app = require('http').createServer(handler);
var server = app.listen(5001);
var io = require('socket.io').listen(server);
var fs = require('fs');
var redis = require('redis').createClient();
var consts = require('./const.js');
var http = require('http');
var utf8 = require('utf8');
http.post = require('http-post');

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

redis.subscribe(consts.SOCK_CHANNEL);

redis.on('message', function(channel, message){
  console.log('got redis message ' + message);
  msg = JSON.parse(message);
  msg["test"] =  utf8.encode("искренний");
  for (var i = 0; i < msg.id_to.length; i++) {
    io.to(msg.id_to[i]).emit('event', message);
    console.log('sending message to ' + msg.id_to[i]);
  }
});

io.on('connection', function(socket){
  console.log(socket.id + ' connected');

  msg = JSON.stringify( { msg_type: consts.SOCK_MSG_TYPE_ANNOUNCE_SOCKETID, msg_body: socket.id } );
  io.to(socket.id).emit('event', msg);

  socket.on('message', function(message){
    console.log('got message from client: ' + message);
    msg = JSON.parse(message);
    if (msg.id_to != null) {
      for (var i = 0; i < msg.id_to.length; i++) {
        io.to(msg.id_to[i]).emit('event', message);
      }
    } else {
      http.post(consts.RAILS_SERVER, msg, function(res){
        res.setEncoding('utf8');
        res.on('data', function(chunk) {
          console.log(chunk);
        });
      });      
    }
  });

  socket.on('disconnect', function() {
    console.log('Disconnected ' + socket.id);
    //msg = JSON.stringify( {msg_type: consts.SOCK_MSG_TYPE_SOCKET_CLOSE, msg_body: socket.id } );
    msg = {msg_type: consts.SOCK_MSG_TYPE_SOCKET_CLOSE, msg_body: socket.id };
    http.post(consts.RAILS_SERVER, msg, function(res){
      res.setEncoding('utf8');
      res.on('data', function(chunk) {
        console.log(chunk);
      });
    });
  });

});
