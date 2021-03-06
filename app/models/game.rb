require 'protocol'

class Game < ActiveRecord::Base

  STATUS_SEARCHING_PLAYERS = 0
  STATUS_IN_PROGRESS = 1
  STATUS_COMPLETED = 2

  PLAYER_STATUS_WAITING = "player_waiting"
  PLAYER_STATUS_THINKING = "player_thinking"
  PLAYER_STATUS_ANSWERED = "player_answered"

  QUESTIONS_PER_GAME = 25

  def start_game
    details = JSON.parse(self.details)
    if (details[Constants::JSON_GAME_PLAYERS].length > 1 )
      msg_to = details[Constants::JSON_GAME_PLAYERS].keys
      msg_type = Constants::SOCK_MSG_TYPE_GAME_START
      msg_body = details
      message = Protocol.make_msg(msg_to, msg_type, msg_body)
      $redis.publish Constants::SOCK_CHANNEL, message
      next_question
    end
  end

  def next_question
   details = JSON.parse(self.details)
   ready_players = self.get_ready_players_count
   if ( (details[Constants::JSON_GAME_STATUS] == Game::STATUS_IN_PROGRESS) and ( ready_players == details[Constants::JSON_GAME_PLAYERS].length ) )
     question = Question.make_random
     msg_to = details[Constants::JSON_GAME_PLAYERS].keys
     msg_type = Constants::SOCK_MSG_TYPE_NEW_QUESTION
     msg_body = question
     message = Protocol.make_msg(msg_to, msg_type, msg_body)
     details[Constants::JSON_GAME_CURQUESTION] = question
     details[Constants::JSON_GAME_QUESTIONCNT] = details[Constants::JSON_GAME_QUESTIONCNT] + 1
     self.details = details.to_json
     save
     $redis.publish Constants::SOCK_CHANNEL, message
   end
  end

  def end_game
    details = JSON.parse(self.details)
    players = details[Constants::JSON_GAME_PLAYERS]
    message_to = players.keys
    message = {Constants::JSON_SOCK_MSG_TO => message_to, Constants::JSON_SOCK_MSG_TYPE => Constants::SOCK_MSG_TYPE_GAME_END, Constants::JSON_SOCK_MSG_BODY => self.id}.to_json
    $redis.publish Constants::SOCK_CHANNEL, message
  end

  def self.find_by_socket_id(socket_id)
    res = []
    games = Game.all
    games.each do |game|
      game_details = JSON.parse(game.details)
      players = game_details[Constants::JSON_GAME_PLAYERS]
      players.each do |sockid, status|
        logger.debug("Comparing " + sockid + " and " + socket_id)
        if ( sockid == socket_id )
          res << game
        end
      end
    end
    return res
  end

  def get_ready_players_count
    game_details = JSON.parse(self.details)
    players = game_details[Constants::JSON_GAME_PLAYERS]
    ready_players = 0
    players.each do |sockid, status|
      if ( players[sockid] == Game::PLAYER_STATUS_WAITING )
        ready_players = ready_players + 1
      end
    end
    return ready_players
  end

  def get_players_count
    game_details = JSON.parse(game.details)
    players = game_details[Constants::JSON_GAME_PLAYERS]
    return players.length
  end

end
