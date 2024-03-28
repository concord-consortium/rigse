class API::V1::ResearcherClassesController < API::APIController
  include Rails.application.routes.url_helpers

  public

  def index
    authorize [:api, :v1, :report_user]

    render :json => query(params, current_user)
  end

  private

  def query(options, user)

    results = {}

    scopes = {
      teachers: Pundit.policy_scope(user, Portal::Teacher),
      cohorts: Pundit.policy_scope(user, Admin::Cohort),
      runnables: Pundit.policy_scope(user, Portal::Offering)
                  .joins("INNER JOIN external_activities ON external_activities.id = portal_offerings.runnable_id")
                  .where("portal_offerings.runnable_type = 'ExternalActivity'"),
      classes: Pundit.policy_scope(user, Portal::Clazz)
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

    ids = {}

    if options[:project_id] && !options[:project_id].empty?
      ids[:project_id] = options[:project_id].to_i
    end

    # Filter by project_id if provided. It happens on Resaercher Classes page.
    if ids.has_key?(:project_id)
      scopes[:teachers] = filter_teachers_by_project_id(scopes[:teachers], ids[:project_id])
      scopes[:cohorts] = filter_cohorts_by_project_id(scopes[:cohorts], ids[:project_id])
      scopes[:runnables] = filter_runnables_by_project_id(scopes[:runnables], ids[:project_id])
      scopes[:classes] = filter_classes_by_project_id(scopes[:classes], ids[:project_id])
    end

    totals = ActiveModel::Type::Boolean.new.cast(options[:totals])
    if totals
      results[:totals] = {
        teachers: scopes[:teachers].count(),
        cohorts: scopes[:cohorts].count(),
        runnables: scopes[:runnables].distinct.select(:runnable_id).count()
      }
    end

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
        runnables: runnables_query(options, user, scopes, ids),
        classes: classes_query(options, user, scopes, ids)
      }
    end

    return results
  end

  def filter_teachers_by_project_id(teachers_scope, project_id)
    teachers_scope
      .joins("INNER JOIN admin_cohort_items ON admin_cohort_items.item_id = portal_teachers.id")
      .joins("INNER JOIN admin_cohorts ON admin_cohorts.id = admin_cohort_items.admin_cohort_id")
      .where("admin_cohort_items.item_type = 'Portal::Teacher' AND admin_cohorts.project_id = ?", project_id)
  end

  def filter_cohorts_by_project_id(cohorts_scope, project_id)
    cohorts_scope
      .where("admin_cohorts.project_id = ?", project_id)
  end

  def filter_runnables_by_project_id(runnables_scope, project_id)
    runnables_scope
      .joins("INNER JOIN portal_teacher_clazzes ptc2 ON portal_offerings.clazz_id = ptc2.clazz_id")
      .joins("INNER JOIN admin_cohort_items aci ON aci.item_id = ptc2.teacher_id")
      .joins("INNER JOIN admin_cohorts ON admin_cohorts.id = aci.admin_cohort_id")
      .where("aci.item_type = 'Portal::Teacher' AND admin_cohorts.project_id = ?", project_id)
  end

  def filter_classes_by_project_id(classes_scope, project_id)
    classes_scope
      .joins("INNER JOIN portal_teacher_clazzes ptc2 ON portal_clazzes.id = ptc2.clazz_id")
      .joins("INNER JOIN admin_cohort_items aci ON aci.item_id = ptc2.teacher_id")
      .joins("INNER JOIN admin_cohorts ON admin_cohorts.id = aci.admin_cohort_id")
      .where("aci.item_type = 'Portal::Teacher' AND admin_cohorts.project_id = ?", project_id)
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
        .where("aci2.item_type = 'Portal::Teacher'")
        .joins("INNER JOIN portal_teacher_clazzes ptc2 ON aci2.item_id = ptc2.teacher_id")
        .joins("INNER JOIN portal_offerings ON portal_offerings.clazz_id = ptc2.clazz_id")
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
        .joins("INNER JOIN portal_teacher_clazzes ptc2 ON portal_offerings.clazz_id = ptc2.clazz_id")
        .joins("INNER JOIN admin_cohort_items aci ON aci.item_id = ptc2.teacher_id")
        .where("aci.item_type = 'Portal::Teacher' AND aci.admin_cohort_id IN (?)", ids[:cohorts])
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

  def classes_query(options, user, scopes, ids)
    if query_not_limited?(options, ids)
      return []
    end

    query_scope = scopes[:classes]

    if ids.has_key?(:cohorts)
      query_scope = query_scope
        .joins("INNER JOIN portal_teacher_clazzes ptc2 ON portal_clazzes.id = ptc2.clazz_id")
        .joins("INNER JOIN admin_cohort_items aci ON aci.item_id = ptc2.teacher_id")
        .where("aci.item_type = 'Portal::Teacher' AND aci.admin_cohort_id IN (?)", ids[:cohorts])
    end

    if ids.has_key?(:teachers)
      query_scope = query_scope
        .joins("INNER JOIN portal_teacher_clazzes ptc2 ON portal_clazzes.id = ptc2.clazz_id")
        .where("ptc2.teacher_id IN (?)", ids[:teachers])
    end

    if ids.has_key?(:runnables)
      query_scope = query_scope
        .joins("INNER JOIN portal_offerings ON portal_offerings.clazz_id = portal_clazzes.id")
        .where("portal_offerings.runnable_type = 'ExternalActivity' AND portal_offerings.runnable_id IN (?)", ids[:runnables])
    end

    query_scope
      .distinct
      .map do |c|
        hash = {}
        hash[:label] = c.name # required by JS code, fix it?
        hash[:name] = c.name
        hash[:teacher_names] = c.teachers.map { |t| "#{t.user.first_name} #{t.user.last_name}" }.join(", ")
        hash[:cohort_names] = c.teachers.map { |t| t.cohorts.map(&:name) }.flatten.uniq.join(", ")
        hash[:class_url] = materials_portal_clazz_url(c.id, researcher: true)
        hash
      end
  end

  def query_not_limited?(options, ids)
    !options[:load_all] && !ids.has_key?(:teachers) && !ids.has_key?(:cohorts) && !ids.has_key?(:runnables)
  end

end
