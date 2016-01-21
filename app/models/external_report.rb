class ExternalReport < ActiveRecord::Base
  belongs_to :client
  has_many :external_activities
  attr_accessible :name, :url, :launch_text, :client_id, :client
  ReportTokenValidFor = 2.hours

  def options_for_client
    Client.all.map { |c| [c.name, c.id] }
  end

  # Return a the external_report url
  # with parameters for the offering_api_url
  # and the short-lived bearer token for the user.
  def url_for(api_offering_url, user)
    grant = client.updated_grant_for(user, ReportTokenValidFor)
    token = grant.access_token
    "#{url}?offering=#{api_offering_url}&token=#{token}"
  end

end
