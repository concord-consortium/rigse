class ExternalReport < ActiveRecord::Base

  OfferingReport = 'offering'
  ClassReport = 'class'
  ReportTypes = [OfferingReport, ClassReport]
  belongs_to :client
  has_many :external_activities
  attr_accessible :name, :url, :launch_text, :client_id, :client, :report_type

  ReportTokenValidFor = 2.hours

  def options_for_client
    Client.all.map { |c| [c.name, c.id] }
  end

  def options_for_report_type
    ReportTypes.map { |rt| [rt, rt] }
  end

  # Return a the external_report url and the short-lived bearer token for the user.
  def url_for_offering(offering, user, protocol, host)
    grant = client.updated_grant_for(user, ReportTokenValidFor)
    if user.portal_teacher
      grant.teacher = user.portal_teacher
      grant.save!
    end
    token = grant.access_token
    username = user.login
    routes = Rails.application.routes.url_helpers
    offering_url = CGI.escape(routes.api_v1_offering_url(offering.id, protocol: protocol, host: host))
    class_id = offering.clazz.id
    class_offerings_url = CGI.escape(routes.api_v1_offerings_url(class_id: class_id, protocol: protocol, host: host))
    class_url = CGI.escape(routes.api_v1_class_url(class_id, protocol: protocol, host: host))
    "#{url}?reportType=offering&offering=#{offering_url}&classOfferings=#{class_offerings_url}&class=#{class_url}&token=#{token}&username=#{username}"
  end

  def url_for_class(class_id, user, protocol, host)
    grant = client.updated_grant_for(user, ReportTokenValidFor)
    token = grant.access_token
    username = user.login
    routes = Rails.application.routes.url_helpers
    class_url = CGI.escape(routes.api_v1_class_url(class_id, protocol: protocol, host: host))
    class_offerings_url = CGI.escape(routes.api_v1_offerings_url(class_id: class_id, protocol: protocol, host: host))
    "#{url}?reportType=class&class=#{class_url}&classOfferings=#{class_offerings_url}&token=#{token}&username=#{username}"
  end

end
