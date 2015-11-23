class UserController < ApplicationController

def create
  json_body = JSON.parse(request.body.read)
end

end
