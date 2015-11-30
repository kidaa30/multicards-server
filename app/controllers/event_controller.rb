require 'constants'

class EventController < ApplicationController
skip_before_filter :verify_authenticity_token
skip_before_filter :check_credentials

def new
  json_body = request.body.read.as_json
  if ((json_body[Constants::JSON_SOCK_MSG_TYPE] == Constants::SOCK_MSG_TYPE_PLAYER_STATUS_UPDATE) and (json_body[Constants::JSON_SOCK_MSG_BODY] != nil))
    msg_body = json_body[Constants::SOCK_MSG_BODY]
    game_id = msg_body[Constants::JSON_SOCK_MSG_GAMEID]
    status_data = msg_body[Constants::JSON_SOCK_MSG_DATA]
    game = Game.find_by_id(game_id)
    game_details = JSON.parse(game.details)
    ready_players = 0
    msg_body.each do |socket_id, status|
      if ( game_details[Constants::JSON_GAME_PLAYERS].has_key?(socket_id) )
        game_details[Constants::JSON_GAME_PLAYERS][socket_id] = status
      end
      if ( status == Game::PLAYER_STATUS_WAITING )
        ready_players = ready_players + 1
      end
    end
    game.details = game_details.to_json
    game.save
    if (game_details[Constants::JSON_GAME_PLAYERS].length == ready_players)
      game.next_question
    end
  elsif ((json_body[Constants::JSON_SOCK_MSG_TYPE] == Constants::SOCK_MSG_TYPE_SOCKET_CLOSE) and (json_body[Constants::JSON_SOCK_MSG_BODY] != nil))
    games = Game.all
    games.each do |game|
      game_details = JSON.parse(game.details)
      players = game_details[Constants::JSON_GAME_PLAYERS]
      players.each do |sockid, status|
        if ( sockid == socket_id )
          message_to = details[Constants::JSON_GAME_PLAYERS].keys
          message = {Constants::JSON_SOCK_MSG_TO => message_to, Constants::JSON_SOCK_MSG_TYPE => Constants::SOCK_MSG_TYPE_GAME_END, Constants::JSON_SOCK_MSG_BODY => game.id}.to_json
          $redis.publish Constants::SOCK_CHANNEL, message
          game.destroy
        end
      end
    end 
  elsif ((json_body[Constants::JSON_SOCK_MSG_TYPE] == Constants::SOCK_MSG_TYPE_PLAYER_ANSWERED) and (json_body[Constants::JSON_SOCK_MSG_BODY] != nil))
     
  end
  msg = { :result => Constants::RESULT_OK }
  render :json => msg
end

end
