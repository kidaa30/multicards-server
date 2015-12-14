class Protocol

  def self.msg_user_status_update(id_from, msg_type, msg_body)
    new_status = msg_body
    Rails.logger.info("Player status update request")
    games = Game.find_by_socket_id(id_from)
    games.each do |game|
      game_details = JSON.parse(game.details)
      game_details[Constants::JSON_GAME_PLAYERS][id_from] = new_status
      game.details = game_details.to_json
      game.save
      if (game_details[Constants::JSON_GAME_PLAYERS].length == game.get_ready_players_count())
        puts game_details[Constants::JSON_GAME_QUESTIONCNT]
        puts Game::QUESTIONS_PER_GAME
        if (game_details[Constants::JSON_GAME_QUESTIONCNT] >= Game::QUESTIONS_PER_GAME)
          game.end_game
          game.destroy
        else
          game.next_question
        end
      end
    end
  end

  def self.msg_socket_close(id_from, msg_type, msg_body)
    puts "Closing socket "
    puts id_from
    socket_id = msg_body
    games = Game.find_by_socket_id(socket_id)
    games.each do |game|
      puts "destroying game with id"
      puts game.id
      game.end_game
      game.destroy
    end
  end

  def self.parse_msg(msg_json)
    id_from = msg_json[Constants::JSON_SOCK_MSG_FROM]
    msg_type = msg_json[Constants::JSON_SOCK_MSG_TYPE]
    msg_body = msg_json[Constants::JSON_SOCK_MSG_BODY]

    if (msg_body == nil)
      res = {   :result => Constants::RESULT_ERROR,
                :code => Constants::ERROR_BODY_FORMAT,
                :message => Constants::MSG_BODY_FORMAT }
      return res
    end

    if (msg_type == Constants::SOCK_MSG_TYPE_PLAYER_STATUS_UPDATE)
      self.msg_user_status_update(id_from, msg_type, msg_body)
    elsif (msg_type == Constants::SOCK_MSG_TYPE_SOCKET_CLOSE)
      self.msg_socket_close(id_from, msg_type, msg_body)
    elsif (msg_type == Constants::SOCK_MSG_TYPE_PLAYER_ANSWERED)
    elsif (msg_type == Constants::SOCK_MSG_TYPE_QUIT_GAME)
      self.msg_socket_close(id_from, msg_type, id_from)    
    end
  
    res = { :result => Constants::RESULT_OK }

  end

  def self.make_msg(id_to, msg_type, msg_body)
    message = {Constants::JSON_SOCK_MSG_TO => id_to, Constants::JSON_SOCK_MSG_TYPE => msg_type, Constants::JSON_SOCK_MSG_BODY => msg_body}.to_json
    return message
  end

end
