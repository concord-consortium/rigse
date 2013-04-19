class Client < ActiveRecord::Base
  attr_accessible :app_id, :app_secret, :name
  def self.authenticate(app_id, app_secret)
    where(["app_id = ? AND app_secret = ?", app_id, app_secret]).first
  end
end
