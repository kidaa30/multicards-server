require 'constants'

class EventController < ApplicationController
skip_before_filter :verify_authenticity_token
skip_before_filter :check_credentials

def new
  json_body = JSON.parse(request.body.read)
  #json_body = request.body.read.as_json
  Rails.logger.info("Event process request")
  if ((json_body[Constants::JSON_SOCK_MSG_TYPE] == Constants::SOCK_MSG_TYPE_PLAYER_STATUS_UPDATE) and (json_body[Constants::JSON_SOCK_MSG_BODY] != nil))
    id_from = json_body[Constants::JSON_SOCK_MSG_FROM]
    new_status = json_body[Constants::JSON_SOCK_MSG_BODY]
    Rails.logger.info("Player status update request")
    games = Game.all
    games.each do |game|
      ready_players = 0
      game_details = JSON.parse(game.details)
      players = game_details[Constants::JSON_GAME_PLAYERS]
      players.each do |sockid, status|
        if ( sockid == id_from )
          game_details[Constants::JSON_GAME_PLAYERS][id_from] = new_status
        end
        if ( game_details[Constants::JSON_GAME_PLAYERS][sockid] == Game::PLAYER_STATUS_WAITING )
          ready_players = ready_players + 1
        end
      end
      if (game_details[Constants::JSON_GAME_PLAYERS].length == ready_players)
        game.next_question
        puts "call next question"
      end
      game.details = game_details.to_json
      game.save
    end

  elsif ((json_body[Constants::JSON_SOCK_MSG_TYPE] == Constants::SOCK_MSG_TYPE_SOCKET_CLOSE) and (json_body[Constants::JSON_SOCK_MSG_BODY] != nil))
    socket_id = json_body[Constants::JSON_SOCK_MSG_BODY]
    games = Game.all
    games.each do |game|
      game_details = JSON.parse(game.details)
      players = game_details[Constants::JSON_GAME_PLAYERS]
      players.each do |sockid, status|
        if ( sockid == socket_id )
          message_to = game_details[Constants::JSON_GAME_PLAYERS].keys
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
