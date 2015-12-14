require 'controllers/test_utils'
require 'rubygems'
require 'socket.io-client-simple'

class GameControllerTest < ActionController::TestCase
  include TestUtils

  @@socket1 = SocketIO::Client::Simple.connect 'http://localhost:5002'
  @@socket2 = SocketIO::Client::Simple.connect 'http://localhost:5002'

  def setup
    @request.headers["Content-Type"] = "application/json"
    @request.headers["Accept"] = "*/*"
    @contact1 = "111111"
    @contact2 = "222222"
    @profile1 = {:email => "test1@test.com", :phone => @contact1, :name => "alex1", :avatar => "http://google.com"}
    @profile2 = {:email => "test2@test.com", :phone => @contact2, :name => "alex2", :avatar => "http://google.com"}
    @@sock1_msg_list = []
    @@sock2_msg_list = []
  end

  def teardown
  end

  test "Should start new game" do
    user_id1 = register(@profile1)
    user_id2 = register(@profile2)
    game_id = new_game(user_id1, @@socket1.session_id)
    game_id = new_game(user_id2, @@socket2.session_id)
    sleep(2)
    assert_equal 1, filter(@@sock1_msg_list, Constants::SOCK_MSG_TYPE_GAME_START).length
    assert_equal 1, filter(@@sock1_msg_list, Constants::SOCK_MSG_TYPE_NEW_QUESTION).length
    assert_equal 1, filter(@@sock2_msg_list, Constants::SOCK_MSG_TYPE_GAME_START).length
    assert_equal 1, filter(@@sock2_msg_list, Constants::SOCK_MSG_TYPE_NEW_QUESTION).length
    assert_equal 2, @@sock1_msg_list.length
    assert_equal 2, @@sock2_msg_list.length
  end

  @@socket1.on :event do |msg|
    msg_json = JSON.parse(msg)
    @@sock1_msg_list << msg_json
  end

  @@socket2.on :event do |msg|
    msg_json = JSON.parse(msg)
    @@sock2_msg_list << msg_json
  end

end
