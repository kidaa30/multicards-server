require 'constants'

class GameController < ApplicationController
skip_before_filter :verify_authenticity_token

def new
  game_details = {}
  game = Game.where(status: Game::STATUS_SEARCHING_PLAYERS).first
  if (game != nil)
    game_details = JSON.parse(game.details)
    game_details[Constants::JSON_GAME_PROFILES][@socket_id] = @user.get_details
    game_details[Constants::JSON_GAME_PLAYERS][@socket_id] = Game::PLAYER_STATUS_WAITING
    game_details[Constants::JSON_GAME_STATUS] = Game::STATUS_IN_PROGRESS
    game_details[Constants::JSON_GAME_QUESTIONCNT] = 0
    game.status = Game::STATUS_IN_PROGRESS
    game.details = game_details.to_json
    game.save
    game.start_game
  else
    game = Game.new
    game_details[Constants::JSON_GAME_PLAYERS] = {@socket_id => Game::PLAYER_STATUS_WAITING}
    game_details[Constants::JSON_GAME_STATUS] = Game::STATUS_SEARCHING_PLAYERS
    game_details[Constants::JSON_GAME_PROFILES] = {@socket_id => @user.get_details}
    game_details[Constants::JSON_GAME_QUESTIONCNT] = 0
    game.status = Game::STATUS_SEARCHING_PLAYERS
    game.details = game_details.to_json
    game.save
  end
  msg = { :result => Constants::RESULT_OK, :data => game_details }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

end
