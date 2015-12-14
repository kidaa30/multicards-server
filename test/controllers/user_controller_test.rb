require 'controllers/test_utils'
require 'rubygems'
require 'socket.io-client-simple'

class UserControllerTest < ActionController::TestCase
  include TestUtils

  def setup
    @socket = SocketIO::Client::Simple.connect 'http://localhost:5001'
    @request.headers["Content-Type"] = "application/json"
    @request.headers["Accept"] = "*/*"
    @contact = "111111"
    @profile = {:email => "test@test.com", :phone => @contact, :name => "alex", :avatar => "http://google.com"}
  end

  def teardown
  end

  test "Should register new user" do
    user_id = register(@profile)
    user = User.where(id: user_id).first
    assert_not_nil user
    assert_equal user.details, @profile.to_json
  end

end
