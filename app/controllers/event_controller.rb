require 'constants'
require 'protocol'

class EventController < ApplicationController
skip_before_filter :verify_authenticity_token
skip_before_filter :check_credentials

def new
  #Rails::logger.debug request.body.read
  json_body = JSON.parse(request.body.read)
  res = Protocol.parse_msg(json_body)
  respond_to do |format|
    format.json  { render :json => res }
  end

end

end
