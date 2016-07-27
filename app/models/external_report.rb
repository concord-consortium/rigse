class ExternalReport < ActiveRecord::Base

  OfferingReport = 'offering'
  ClassReport = 'class'
  TeacherReport = 'teacher'
  ReportTypes = [OfferingReport, ClassReport, TeacherReport]
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

  def offering_api_url(offering_id, protocol, host)
    routes = Rails.application.routes.url_helpers
    opts = {protocol:protocol, host:host}
    case report_type
      when OfferingReport
        routes.api_v1_offering_url(offering_id, opts)
      when ClassReport
        routes.for_class_api_v1_offering_url(offering_id, opts)
      when TeacherReport
        routes.for_teacher_api_v1_offering_url(offering_id, opts)
      else
        routes.api_v1_offering_url(offering_id, opts)
    end
  end

  # Return a the external_report url
  # with parameters for the offering_api_url
  # and the short-lived bearer token for the user.
  def url_for(offering_id, user, protocol, host)
    grant = client.updated_grant_for(user, ReportTokenValidFor)
    token = grant.access_token
    "#{url}?offering=#{offering_api_url(offering_id, protocol, host)}&token=#{token}"
  end

end
