class API::V1::ReportUsersController < API::APIController
  include Rails.application.routes.url_helpers

  public

  def index
    authorize [:api, :v1, :report_user]

    render :json => query(params, current_user)
  end

  # Returns a signed query that can be used by the external researcher report.
  def external_report_query
    authorize [:api, :v1, :report_user]

    teacher_ids = []
    if params[:teachers] && !params[:teachers].empty?
      teacher_ids = teacher_ids + params[:teachers].split(',').map(&:to_i)
    end
    if params[:cohorts] && !params[:cohorts].empty?
      cohort_ids = params[:cohorts].split(',').map(&:to_i)
      teacher_ids = teacher_ids + Admin::CohortItem.distinct.where("item_type = 'Portal::Teacher' AND admin_cohort_id IN (?)", cohort_ids).pluck("item_id")
    end

    if teacher_ids.length > 0
      users = User
        .distinct
        .joins("INNER JOIN portal_teachers ON portal_teachers.user_id = users.id")
        .where("portal_teachers.id IN (?)", teacher_ids)
        .select("users.id, users.login as username, users.first_name, users.last_name")
    else
      users = []
    end

    if params[:runnables] && !params[:runnables].empty?
      runnable_ids = params[:runnables].split(',').map(&:to_i)
      runnables = ExternalActivity
                  .where("id IN (?)", runnable_ids)
                  .select([:id, :url, :name, :tool_id])
                  .includes(:tool)
                  .map do |r|
                    browse_url = browse_external_activity_url(id: r.id, protocol: request.protocol, host: request.host_with_port)
                    {id: r.id, url: r.url, browse_url: browse_url, name: r.name, source_type: r.tool&.source_type }
                  end
    else
      runnables = []
    end

    query = {
      type: "users",
      version: "1.0",
      domain: URI.parse(APP_CONFIG[:site_url]).host,
      users: users,
      runnables: runnables,
      start_date: params[:start_date],
      end_date: params[:end_date]
    }

    signature = OpenSSL::HMAC.hexdigest("SHA256", SignedJWT.hmac_secret, query.to_json)
    render json: {
      json: query,
      signature: signature
    }.to_json
  end

  private

  def query(options, user)

    results = {}

    lara_tool_ids = Tool.where(source_type: "LARA").pluck(:id)

    scopes = {
      teachers: Pundit.policy_scope(user, Portal::Teacher),
      cohorts: Pundit.policy_scope(user, Admin::Cohort),
      runnables: Pundit.policy_scope(user, Portal::Offering)
                  .joins("INNER JOIN external_activities ON external_activities.id = portal_offerings.runnable_id")
                  .where("portal_offerings.runnable_type = 'ExternalActivity'")
    }

    cc_teacher_ids = []
    remove_cc_teachers = ActiveModel::Type::Boolean.new.cast(options[:remove_cc_teachers])
    if remove_cc_teachers
      cc_school_ids = Portal::School.where("name = 'concord consortium'").pluck("id")
      cc_teacher_ids = cc_school_ids.length > 0 && Portal::SchoolMembership
        .where("member_type = 'Portal::Teacher' AND school_id IN (?)", cc_school_ids)
        .pluck("member_id")
      if cc_teacher_ids && cc_teacher_ids.length > 0
        scopes[:teachers] = scopes[:teachers].where("portal_teachers.id NOT IN (?)", cc_teacher_ids)
      end
    end

    totals = ActiveModel::Type::Boolean.new.cast(options[:totals])
    if totals
      results[:totals] = {
        teachers: scopes[:teachers].count(),
        cohorts: scopes[:cohorts].count(),
        runnables: scopes[:runnables].distinct.select(:runnable_id).count()
      }
    end

    ids = {}

    if options[:teachers] && !options[:teachers].empty?
      if /\A(\d+,*)+\z/.match(options[:teachers])
        ids[:teachers] = options[:teachers].split(',').map(&:to_i)
      elsif options[:teachers].length >= 4
        like_holder = "%#{options[:teachers]}%"
        ids[:teachers] = scopes[:teachers]
          .distinct
          .joins(:user)
          .where("(users.login LIKE ?) OR (users.first_name LIKE ?) OR (users.last_name LIKE ?)", like_holder, like_holder, like_holder)
          .pluck("portal_teachers.id")
      end
    end

    ids[:cohorts] = options[:cohorts].split(',').map(&:to_i) if options[:cohorts] && !options[:cohorts].empty?

    if options[:runnables] && !options[:runnables].empty?
      if /\A(\d+,*)+\z/.match(options[:runnables])
        ids[:runnables] = options[:runnables].split(',').map(&:to_i)
      elsif options[:runnables].length >= 4
        ids[:runnables] = scopes[:runnables]
          .distinct
          .where("external_activities.name LIKE ?", "%#{options[:runnables]}%")
          .pluck("runnable_id")
      end
    end

    if options[:load_all]
      case options[:load_all]
      when "teachers"
        results[:hits] = {teachers: teacher_query(options, user, scopes, {})}
      when "cohorts"
        results[:hits] = {cohorts: cohorts_query(options, user, scopes, {})}
      when "runnables"
        results[:hits] = {runnables: runnables_query(options, user, scopes, {})}
      end
    elsif (ids.has_key?(:teachers) || ids.has_key?(:cohorts) || ids.has_key?(:runnables))
      results[:hits] = {
        teachers: teacher_query(options, user, scopes, ids),
        cohorts: cohorts_query(options, user, scopes, ids),
        runnables: runnables_query(options, user, scopes, ids)
      }
    end

    return results
  end

  def teacher_query(options, user, scopes, ids)
    if query_not_limited?(options, ids)
      return []
    end

    query_scope = scopes[:teachers]
    if ids.has_key?(:teachers)
      query_scope = query_scope.where("portal_teachers.id IN (?)", ids[:teachers])
    end

    if ids.has_key?(:cohorts)
      query_scope = query_scope
        .joins("INNER JOIN admin_cohort_items ON admin_cohort_items.item_id = portal_teachers.id")
        .where("admin_cohort_items.item_type = 'Portal::Teacher' AND admin_cohort_items.admin_cohort_id IN (?)", ids[:cohorts])
    end

    if ids.has_key?(:runnables)
      query_scope = query_scope
        .joins("INNER JOIN portal_teacher_clazzes ON portal_teacher_clazzes.teacher_id = portal_teachers.id")
        .joins("INNER JOIN portal_offerings ON portal_offerings.clazz_id = portal_teacher_clazzes.clazz_id")
        .where("portal_offerings.runnable_type = 'ExternalActivity' AND portal_offerings.runnable_id IN (?)", ids[:runnables])
    end

    query_scope
      .distinct
      .joins(:user)
      .select("portal_teachers.id, CONCAT(users.first_name, ' ', users.last_name, ' (', users.login ,')') AS label")
  end

  def cohorts_query(options, user, scopes, ids)
    if query_not_limited?(options, ids)
      return []
    end

    query_scope = scopes[:cohorts]
    if ids.has_key?(:cohorts)
      query_scope = query_scope.where("admin_cohorts.id IN (?)", ids[:cohorts])
    end

    if ids.has_key?(:teachers)
      query_scope = query_scope
        .joins("INNER JOIN admin_cohort_items ON admin_cohort_items.admin_cohort_id = admin_cohorts.id")
        .where("admin_cohort_items.item_type = 'Portal::Teacher' AND admin_cohort_items.item_id IN (?)", ids[:teachers])
    end

    if ids.has_key?(:runnables)
      # NOTE: the aci2 alias is required as admin_cohort_items is also joined if there are teachers ids
      query_scope = query_scope
        .joins("INNER JOIN admin_cohort_items aci2 ON aci2.admin_cohort_id = admin_cohorts.id")
        .joins("INNER JOIN portal_offerings ON portal_offerings.runnable_id = aci2.item_id")
        .where("aci2.item_type = 'ExternalActivity'")
        .where("portal_offerings.runnable_type = 'ExternalActivity' AND portal_offerings.runnable_id IN (?)", ids[:runnables])
    end

    query_scope
      .joins("LEFT OUTER JOIN admin_projects ON admin_projects.id = admin_cohorts.project_id")
      .distinct
      .select("admin_cohorts.id, CONCAT(COALESCE(admin_projects.name,'No Project'), ': ', admin_cohorts.name) as label")
      .order("label")
  end

  def runnables_query(options, user, scopes, ids)
    if query_not_limited?(options, ids)
      return []
    end

    query_scope = scopes[:runnables]
    if ids.has_key?(:runnables)
      query_scope = query_scope.where("runnable_type = 'ExternalActivity' AND runnable_id IN (?)", ids[:runnables])
    end

    if ids.has_key?(:cohorts)
      query_scope = query_scope
        .joins("INNER JOIN admin_cohort_items ON admin_cohort_items.item_id = portal_offerings.runnable_id")
        .where("admin_cohort_items.item_type = 'ExternalActivity' AND admin_cohort_items.admin_cohort_id IN (?)", ids[:cohorts])
    end

    if ids.has_key?(:teachers)
      query_scope = query_scope
        .joins("INNER JOIN portal_teacher_clazzes ptc2 ON portal_offerings.clazz_id = ptc2.clazz_id")
        .where("ptc2.teacher_id IN (?)", ids[:teachers])
    end

    query_scope
      .distinct
      .select("external_activities.id, external_activities.name as label")
  end

  def query_not_limited?(options, ids)
    !options[:load_all] && !ids.has_key?(:teachers) && !ids.has_key?(:cohorts) && !ids.has_key?(:runnables)
  end

end
