require 'constants'
module TestUtils

  def register(profile)
    @controller = UserController.new
    post :new, profile.to_json
    assert_response :success
    user_id = JSON.parse(@response.body)['data']['id']
  end

  def new_game(userid, socketid)
    @controller = GameController.new
    @request.headers[Constants::HEADER_USERID] = userid
    @request.headers[Constants::HEADER_SOCKETID] = socketid
    post :new
    game_id = JSON.parse(@response.body)['data']['id']    
  end

  def filter(list, msg_type)
    res = []
    list.each do |msg|
      if msg[Constants::JSON_SOCK_MSG_TYPE] == msg_type
        res << msg
      end
    end
    return res
  end

end
