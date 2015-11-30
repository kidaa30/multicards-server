class Game < ActiveRecord::Base

  STATUS_SEARCHING_PLAYERS = 0
  STATUS_IN_PROGRESS = 1
  STATUS_COMPLETED = 2

  PLAYER_STATUS_WAITING = "player_waiting"
  PLAYER_STATUS_THINKING = "player_thinking"
  PLAYER_STATUS_ANSWERED = "player_answered"

  def start_game
    details = JSON.parse(self.details)
    if (details[Constants::JSON_GAME_PLAYERS].length > 1 )
      message_to = details[Constants::JSON_GAME_PLAYERS].keys
      message = {Constants::JSON_SOCK_MSG_TO => message_to, Constants::JSON_SOCK_MSG_TYPE => Constants::SOCK_MSG_TYPE_GAME_START, Constants::JSON_SOCK_MSG_BODY => details}.to_json
      $redis.publish Constants::SOCK_CHANNEL, message
      next_question
    end
  end

  def next_question
   details = JSON.parse(self.details)
   ready_players = 0
   details[Constants::JSON_GAME_PLAYERS].each do |player_id, status|
     if ( status == PLAYER_STATUS_WAITING )
       ready_players = ready_players + 1
     end
   end
   if ( (details[Constants::JSON_GAME_STATUS] == Game::STATUS_IN_PROGRESS) and ( ready_players == details[Constants::JSON_GAME_PLAYERS].length ) )
     question = Question.make_random
     message_to = details[Constants::JSON_GAME_PLAYERS].keys
     message = {Constants::JSON_SOCK_MSG_TO => message_to, Constants::JSON_SOCK_MSG_TYPE => Constants::SOCK_MSG_TYPE_NEW_QUESTION, Constants::JSON_SOCK_MSG_BODY => question}.to_json
     details[Constants::JSON_GAME_CURQUESTION] = question
     self.details = details.to_json
     save
     $redis.publish Constants::SOCK_CHANNEL, message
   end
  end

  def end_game
  end

end
