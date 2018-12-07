class ExternalReport < ActiveRecord::Base

  OfferingReport = 'offering'
  ClassReport = 'class'
  ResearcherReport = 'researcher'
  ReportTypes = [OfferingReport, ClassReport, ResearcherReport]
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
    routes = Rails.application.routes.url_helpers
    class_id = offering.clazz.id
    url_options = {protocol: protocol, host: host}
    add_query_params(url, {
      reportType:     'offering',
      offering:       routes.api_v1_offering_url(offering.id, url_options),
      classOfferings: routes.api_v1_offerings_url(url_options.merge(class_id: class_id)),
      class:          routes.api_v1_class_url(class_id, url_options),
      token:          grant.access_token,
      username:       user.login
    })
  end

  def url_for_class(class_id, user, protocol, host)
    grant = client.updated_grant_for(user, ReportTokenValidFor)
    routes = Rails.application.routes.url_helpers
    url_options = {protocol: protocol, host: host}
    add_query_params(url, {
      reportType:     'class',
      class:          routes.api_v1_class_url(class_id, url_options),
      classOfferings: routes.api_v1_offerings_url(url_options.merge(class_id: class_id)),
      token:          grant.access_token,
      username:       user.login
    })
  end

  private
  # this returns the url with the new params merged in
  def add_query_params(url, params)
    uri = URI.parse(url)
    query_hash = Rack::Utils.parse_query(uri.query)
    query_hash.merge!(params)
    uri.query = query_hash.to_query
    uri.to_s
  end
end
