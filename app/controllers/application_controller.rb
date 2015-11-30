class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :check_credentials

  def check_credentials()
    user_id = request.headers[Constants::HEADER_USERID]
    @socket_id = request.headers[Constants::HEADER_SOCKETID]
    @user = User.find_by_id(user_id)
    if @user == nil
      msg = { :result => "ERROR", :msg => "Wrong user id" }
      respond_to do |format|
        format.json  { render :json => msg } 
      end
    else
      @user_details = JSON.parse(@user.details)  
    end
  end

end
