class ExternalReport < ActiveRecord::Base
  belongs_to :client
  has_many :external_activities
  attr_accessible :name, :url, :launch_text, :client_id, :client

  def options_for_client
    Client.all.map { |c| [c.name, c.id] }
  end

end
