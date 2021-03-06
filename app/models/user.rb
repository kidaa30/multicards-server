require 'constants'
class User < ActiveRecord::Base

  def update(json_body)
    if ((self.details == nil) or (self.details.length == 0))
      cur_details = {}
    else
      cur_details = JSON.parse(self.details)
    end

    json_body.each do |key, value|
        cur_details[key] = value
    end
    self.details = cur_details.to_json
  end

  def get_details
    details = JSON.parse(self.details)
    details[Constants::JSON_USER_ID] = self.id
    return details
  end

end
