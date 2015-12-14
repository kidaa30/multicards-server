require 'constants'
require 'net/http'

class CardsetController < ApplicationController
skip_before_filter :verify_authenticity_token
before_filter :check_credentials

def get
  json_body = JSON.parse(request.body.read)
  cardsets = Cardset.all
  msg = { :result => Constants::RESULT_OK, :data => cardsets.to_json }
  respond_to do |format|
    format.json  { render :json => msg }
  end    
end

def import
  cardsetid = request.headers['cardsetid']
  url = URI.parse('https://api.quizlet.com/2.0/sets/'+cardsetid)
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
  if res.code == 200
    cardset = Cardset.new
    cardset.gid = "quizlet_" + cardsetid
    terms = JSON.parse(res.body)[:terms]
    terms.each do |term|
      card = Card.new
    end 
  end
end

end
