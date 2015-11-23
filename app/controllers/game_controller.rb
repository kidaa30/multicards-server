class GameController < ApplicationController
skip_before_filter :verify_authenticity_token

def new
  json_body = JSON.parse(request.body.read)
  $redis.publish 'events', json_body.to_json
  msg = { :result => "OK" }
  respond_to do |format|
    format.json  { render :json => msg }
  end
end

end
