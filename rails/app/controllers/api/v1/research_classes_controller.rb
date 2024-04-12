class API::V1::ResearchClassesController < API::APIController
  include Rails.application.routes.url_helpers

  public

  def index
    authorize [:api, :v1, :report_user]
    render :json => query(params, current_user)
  end

  private

  def query(options, user)
    results = {}

    teachers = Pundit.policy_scope(user, Portal::Teacher)
    cohorts = Pundit.policy_scope(user, Admin::Cohort)
    runnables = Pundit.policy_scope(user, Portal::Offering)
                .joins("INNER JOIN external_activities ON external_activities.id = portal_offerings.runnable_id AND portal_offerings.runnable_type = 'ExternalActivity'")
                .where(external_activities: { is_archived: false })
    classes = Pundit.policy_scope(user, Portal::Clazz)

    cc_teacher_ids = []
    remove_cc_teachers = ActiveModel::Type::Boolean.new.cast(options[:remove_cc_teachers])
    if remove_cc_teachers
      cc_school_ids = Portal::School.where("name = 'concord consortium'").pluck("id")
      cc_teacher_ids = cc_school_ids.length > 0 && Portal::SchoolMembership
        .where("member_type = 'Portal::Teacher' AND school_id IN (?)", cc_school_ids)
        .pluck("member_id")
      if cc_teacher_ids && cc_teacher_ids.length > 0
        # Filter teachers
        teachers = teachers.where.not(id: cc_teacher_ids)
        # Filter classes owned by those teachers
        classes = classes.joins(:teacher_clazzes).where.not(portal_teacher_clazzes: { teacher_id: cc_teacher_ids })
      end
    end

    ids = {}
    ids[:project_id] = options[:project_id].to_i if options[:project_id] && !options[:project_id].empty?
    ids[:teachers] = options[:teachers].split(',').map(&:to_i) if options[:teachers] && !options[:teachers].empty?
    ids[:cohorts] = options[:cohorts].split(',').map(&:to_i) if options[:cohorts] && !options[:cohorts].empty?
    ids[:runnables] = options[:runnables].split(',').map(&:to_i) if options[:runnables] && !options[:runnables].empty?

    classes_subquery = classes_query(options, user, classes, ids)
    classes_ids_subquery = classes_subquery.select(:id)

    if options[:load_only]
      # Load results just for one field and no totals
      case options[:load_only]
      when "teachers"
        results[:hits] = {teachers: teacher_query(options, user, teachers, classes_ids_subquery, ids[:project_id])}
      when "cohorts"
        results[:hits] = {cohorts: cohorts_query(options, user, cohorts, classes_ids_subquery, ids[:project_id])}
      when "runnables"
        results[:hits] = {runnables: runnables_query(options, user, runnables, classes_ids_subquery, ids[:project_id])}
      end
    else
      results[:hits] = {
        classes: classes_mapping(classes_subquery)
      }
      results[:totals] = {
        teachers: teacher_query(options, user, teachers, classes_ids_subquery, ids[:project_id], true),
        cohorts: cohorts_query(options, user, cohorts, classes_ids_subquery, ids[:project_id], true),
        runnables: runnables_query(options, user, runnables, classes_ids_subquery, ids[:project_id], true),
        classes: results[:hits][:classes].count
      }
    end

    return results
  end

  def teacher_query(options, user, scope, clazz_ids_subquery, project_id, count_only = false)
    scope = scope
      .joins("INNER JOIN portal_teacher_clazzes ON portal_teacher_clazzes.teacher_id = portal_teachers.id")
      .where(portal_teacher_clazzes: { clazz_id: clazz_ids_subquery })
      # Note that we still need to filter by project_id, as one class might belong to two projects if
      # it has two teachers, each belonging to a different project.
      .joins("INNER JOIN admin_cohort_items ON admin_cohort_items.item_id = portal_teachers.id AND admin_cohort_items.item_type = 'Portal::Teacher'")
      .joins("INNER JOIN admin_cohorts ON admin_cohorts.id = admin_cohort_items.admin_cohort_id")
      .joins("INNER JOIN admin_projects ON admin_projects.id = admin_cohorts.project_id")
      .where(admin_projects: { id: project_id })
      .distinct

    if count_only
      scope.count("portal_teachers.id")
    else
      scope.joins(:user)
        .select("portal_teachers.id, CONCAT(users.first_name, ' ', users.last_name, ' (', users.login ,')') AS label")
        .order("label")
    end
  end

  def cohorts_query(options, user, scope, clazz_ids_subquery, project_id, count_only = false)
    scope = scope
      .joins("INNER JOIN admin_cohort_items ON admin_cohort_items.item_type = 'Portal::Teacher' AND admin_cohort_items.admin_cohort_id = admin_cohorts.id")
      .joins("INNER JOIN portal_teacher_clazzes ON admin_cohort_items.item_id = portal_teacher_clazzes.teacher_id")
      .where(portal_teacher_clazzes: { clazz_id: clazz_ids_subquery })
      # Note that we still need to filter by project_id, as one class might belong to two projects if
      # it has two teachers, each belonging to a different project.
      .joins("INNER JOIN admin_projects ON admin_projects.id = admin_cohorts.project_id")
      .where(admin_projects: { id: project_id })
      .distinct

    if count_only
      scope.count("admin_cohorts.id")
    else
      scope
        .select("admin_cohorts.id, CONCAT(COALESCE(admin_projects.name,'No Project'), ': ', admin_cohorts.name) as label")
        .order("label")
    end
  end

  def runnables_query(options, user, scope, clazz_ids_subquery, project_id, count_only = false)
    scope = scope
      .where(clazz_id: clazz_ids_subquery)
      # Note that we still need to filter by project_id, as one class might belong to two projects if
      # it has two teachers, each belonging to a different project.
      .joins("INNER JOIN portal_teacher_clazzes ON portal_teacher_clazzes.clazz_id = portal_offerings.clazz_id")
      .joins("INNER JOIN admin_cohort_items ON admin_cohort_items.item_id = portal_teacher_clazzes.teacher_id AND admin_cohort_items.item_type = 'Portal::Teacher'")
      .joins("INNER JOIN admin_cohorts ON admin_cohorts.id = admin_cohort_items.admin_cohort_id")
      .joins("INNER JOIN admin_projects ON admin_projects.id = admin_cohorts.project_id")
      .where(admin_projects: { id: project_id })
      .distinct

    if count_only
      scope.count("external_activities.id")
    else
      scope
        .select("external_activities.id, external_activities.name as label")
        .order("label")
    end
  end

  def classes_query(options, user, scope, ids)
    scope = scope
      .joins("INNER JOIN portal_teacher_clazzes ptc2 ON portal_clazzes.id = ptc2.clazz_id")
      .joins("INNER JOIN admin_cohort_items aci ON aci.item_id = ptc2.teacher_id")
      .joins("INNER JOIN admin_cohorts ON admin_cohorts.id = aci.admin_cohort_id")
      .where("aci.item_type = 'Portal::Teacher' AND admin_cohorts.project_id = ?", ids[:project_id])

    if ids.has_key?(:cohorts)
      scope = scope
        .joins("INNER JOIN portal_teacher_clazzes ptc2 ON portal_clazzes.id = ptc2.clazz_id")
        .joins("INNER JOIN admin_cohort_items aci ON aci.item_id = ptc2.teacher_id")
        .where("aci.item_type = 'Portal::Teacher' AND aci.admin_cohort_id IN (?)", ids[:cohorts])
    end

    if ids.has_key?(:teachers)
      scope = scope
        .joins("INNER JOIN portal_teacher_clazzes ptc2 ON portal_clazzes.id = ptc2.clazz_id")
        .where("ptc2.teacher_id IN (?)", ids[:teachers])
    end

    if ids.has_key?(:runnables)
      scope = scope
        .joins("INNER JOIN portal_offerings ON portal_offerings.clazz_id = portal_clazzes.id")
        .where("portal_offerings.runnable_type = 'ExternalActivity' AND portal_offerings.runnable_id IN (?)", ids[:runnables])
    end

    scope.distinct
  end

  def classes_mapping(classes_query)
    classes_query.map do |c|
      {
        id: c.id,
        name: c.name,
        teacher_names: c.teachers.map { |t| "#{t.user.first_name} #{t.user.last_name}" }.join(", "),
        cohort_names: c.teachers.map { |t| t.cohorts.map(&:name) }.flatten.uniq.join(", "),
        school_name: c.teacher_school ? c.teacher_school.name : "",
        class_url: materials_portal_clazz_url(c.id, researcher: true)
      }
    end
  end
end
