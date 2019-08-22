class ExternalReport < ActiveRecord::Base

  OfferingReport = 'offering'
  ClassReport = 'class'
  ResearcherLearnerReport = 'researcher-learner'
  ResearcherUserReport = 'researcher-user'
  DeprecatedReport = 'deprecated-report'
  ReportTypes = [OfferingReport, ClassReport, ResearcherLearnerReport, ResearcherUserReport, DeprecatedReport]
  belongs_to :client
  has_many :external_activity_reports
  has_many :external_activities, through: :external_activity_reports

  attr_accessible :name, :url, :launch_text, :client_id, :client, :report_type, :allowed_for_students,
    :default_report_for_source_type, :individual_student_reportable, :individual_activity_reportable

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

    if report_type === DeprecatedReport
      params = deprecated_report_params(offering, grant, url_options, additional_params)
    else
      params = offering_report_params(offering, grant, user, url_options, additional_params)
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

  def deprecated_report_params(offering, grant, url_options, additional_params = {})
    routes = Rails.application.routes.url_helpers
    # Deprecated, default report service that was provided by Portal. Pretty similar to offering report,
    # but it uses different API (Report API) and different set of launch URL parameters.
    report_url_extra_params = {}
    # Note that depreciated report expects ID of the Student model (not ID of the User model).
    if additional_params[:student_id]
      report_url_extra_params[:student_ids] = [ additional_params[:student_id] ]
    end
    if additional_params[:activity_id]
      report_url_extra_params[:activity_id] = additional_params[:activity_id]
    end
    {
      reportUrl: routes.api_v1_report_url(offering.id, url_options.merge(report_url_extra_params)),
      token: grant.access_token
    }
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
    if additional_params[:activity_id]
      # New reports only support activity INDEX (within investigation) instead of the internal activity ID.
      activity = Activity.find(additional_params[:activity_id])
      params[:activityIndex] = activity.investigation.activities.index(activity)
    end
    params
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
