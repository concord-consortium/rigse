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

  # Raised for a launch this report's client cannot take: a scoped client gets its token
  # from the code flow, never in a URL, and only a class launch knows how to start that.
  class LaunchNotSupported < StandardError; end

  def options_for_client
    Client.all.map { |c| [c.name, c.id] }
  end

  def options_for_report_type
    ReportTypes.map { |rt| [rt, rt] }
  end

  # Return a the external_report url and the short-lived bearer token for the user.
  def url_for_offering(offering, user, protocol, host, additional_params = {})
    raise LaunchNotSupported, "#{name} is launched by class, through the OAuth2 code flow" if client&.scoped?
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
    # New reports expect ID of the User model (not ID of the Student model).
    params[:studentId] = Portal::Student.find(additional_params[:student_id]).user.id if additional_params[:student_id]
    params[:researcher] = 'true' if additional_params[:researcher]
    params
  end

  def url_for_class(clazz, user, protocol, host, additional_params = {})
    return oauth2_url_for_class(clazz, user, protocol, host) if client&.scoped?
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
    params[:logging] = 'true' if clazz.logging
    params[:researcher] = 'true' if additional_params[:researcher]
    add_query_params(url, params)
  end

  private
  # A report whose client has scopes gets no token in its URL: the link names the class, and
  # the app asks the portal for a token itself with the OAuth2 code flow and PKCE, binding
  # that class as the token's context. The parameters follow the OAuth2 launch convention
  # of ExternalActivity#url (authDomain, loginHint).
  def oauth2_url_for_class(clazz, user, protocol, host)
    add_query_params(url, {
      # the root URL, as root_url gives ExternalActivity#url; callers pass the protocol both
      # as request.protocol ("https://") and bare ("https"), as the url helpers accept
      authDomain: "#{protocol.to_s.delete_suffix('://')}://#{host}/",
      classId:    clazz.id,
      loginHint:  user.id
    })
  end

  # this returns the url with the new params merged in
  def add_query_params(url, params)
    uri = URI.parse(url)
    query_hash = Rack::Utils.parse_query(uri.query)
    query_hash.merge!(params)
    uri.query = query_hash.to_query
    uri.to_s
  end
end
