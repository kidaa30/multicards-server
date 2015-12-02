var io = require('socket.io-client')
, assert = require('assert')
, expect = require('expect.js');
var redis = require('redis').createClient();
var url = 'http://localhost:5001';
var consts = require('./consts.js');
var should = require('should');

describe('Suite of unit tests', function() {

    var socket;
    var options =  {'reconnection delay' : 0, 'reopen delay' : 0, 'force new connection' : true};

    beforeEach(function(done) {
        // Setup
        socket = io.connect(url, options);
        socket.on('connect', function() {
            console.log('worked...');
            done();
        });
        socket.on('disconnect', function() {
            console.log('disconnected...');
        })
    });

    afterEach(function(done) {
        if(socket.connected) {
            console.log('disconnecting...');
            socket.disconnect();
        } else {
            console.log('no connection to break...');
        }
        done();
    });

    describe('First test', function() {

        it('Should receive socket id', function(done){
          client1 = io.connect(url, options);
          client1.on('event', function(msg){
            msg_json = JSON.parse(msg);
            msg_json.msg_body.should.equal(client1.io.engine.id);
            msg_json.msg_type.should.equal(consts.SOCK_MSG_TYPE_ANNOUNCE_SOCKETID);
            client1.disconnect();
            done();
          });
 
        });

        it('Should send message to another client', function(done) {
            client1 = io.connect(url, options);
            client2 = io.connect(url, options);
            client2.on('connect', function(data){
              test_msg_json = {id_to: [client2.io.engine.id], msg_type: consts.SOCK_MSG_TYPE_PLAYER_STATUS_UPDATE, msg_body: 'player_waiting'};
              client1.emit("message", JSON.stringify(test_msg_json));
              client2.on("event", function(msg){
                console.log('got message ' + msg);
                msg_json = JSON.parse(msg);
                if (msg_json.msg_type == consts.SOCK_MSG_TYPE_PLAYER_STATUS_UPDATE) {
                  msg_json.id_from.should.equal(client1.io.engine.id);
                  msg_json.msg_body.should.equal(test_msg_json.msg_body);
                  client1.disconnect();
                  client2.disconnect();
                  done();
                }
              });
            });
        });

        it('Should trigger event on rails server', function(done) {
            client1 = io.connect(url, options);
            client1.on('connect', function(data){
              test_msg_json = {id_to: [], msg_type: consts.SOCK_MSG_TYPE_PLAYER_STATUS_UPDATE, msg_body: 'player_waiting'};
              client1.emit("message", JSON.stringify(test_msg_json));
              done();
            });
        });


    });

});
