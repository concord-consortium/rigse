class ExternalReport < ApplicationRecord

  OfferingReport = 'offering'
  ClassReport = 'class'
  ResearcherLearnerReport = 'researcher-learner'
  ResearcherUserReport = 'researcher-user'
  ReportTypes = [OfferingReport, ClassReport, ResearcherLearnerReport, ResearcherUserReport]
  belongs_to :client
  has_many :external_activity_reports
  has_many :external_activities, through: :external_activity_reports

  ReportTokenValidFor = 2.hours

  def options_for_client
    Client.all.map { |c| [c.name, c.id] }
  end

  def options_for_report_type
    ReportTypes.map { |rt| [rt, rt] }
  end

  # Return a the external_report url and the short-lived bearer token for the user.
  def url_for_offering(offering, user, protocol, host, additional_params = {})
    grant = client.updated_grant_for(user, ReportTokenValidFor)
    if user.portal_teacher
      grant.teacher = user.portal_teacher
      grant.save!
    end
    url_options = {protocol: protocol, host: host}

    params = offering_report_params(offering, grant, user, url_options, additional_params)

    if offering.runnable.logging || offering.clazz.logging
      params[:logging] = 'true'
    end

    if allowed_for_students && user.portal_student
      params[:studentId] = user.id
      learner = Portal::Learner.where(offering_id: offering.id, student_id: user.portal_student.id).first
      if learner
        grant.learner = learner
        grant.save!
      end
    end

    add_query_params(url, params)
  end

  def offering_report_params(offering, grant, user, url_options, additional_params = {})
    routes = Rails.application.routes.url_helpers
    class_id = offering.clazz.id
    params = {
      reportType:     'offering',
      offering:       routes.api_v1_offering_url(offering.id, url_options),
      classOfferings: routes.api_v1_offerings_url(url_options.merge(class_id: class_id)),
      class:          routes.api_v1_class_url(class_id, url_options),
      token:          grant.access_token,
      username:       user.login
    }
    if additional_params[:student_id]
      # New reports expect ID of the User model (not ID of the Student model).
      params[:studentId] = Portal::Student.find(additional_params[:student_id]).user.id
    end
    params
  end

  def url_for_class(clazz, user, protocol, host)
    class_id = clazz.id
    grant = client.updated_grant_for(user, ReportTokenValidFor)
    routes = Rails.application.routes.url_helpers
    url_options = {protocol: protocol, host: host}
    params = {
      reportType:     'class',
      class:          routes.api_v1_class_url(class_id, url_options),
      classOfferings: routes.api_v1_offerings_url(url_options.merge(class_id: class_id)),
      token:          grant.access_token,
      username:       user.login
    }
    if clazz.logging
      params[:logging] = 'true'
    end
    add_query_params(url, params)
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
