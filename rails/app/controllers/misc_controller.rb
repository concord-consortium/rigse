class MiscController < ActionController::Base
  # This controller is intended for things that don't need all of the
  # complex setup that happens in ApplicationController. If you have
  # actions that don't need things like authentication, current_visitor,
  # etc. then you can place them here and they will execute more
  # quickly.
  # Also notably, nothing in the chain before this accesses session[],
  # so if a session does not already exist *it will not be created*
  # unless you action accesses session[].

  def stats
    stats = {}
    stats[:teachers] = Portal::Teacher.count
    stats[:students] = Portal::Student.count
    stats[:classes] = Portal::Clazz.count
    stats[:users] = User.count
    stats[:learners] = Portal::Learner.count
    stats[:offerings] = Portal::Offering.count
    stats[:external_activities] = ExternalActivity.count

    # this sql was created because using the active record query language didn't generate the correct distinct ordering
    # additionally it allows us to get all the 'active' stats in one shot
    result = ApplicationRecord.connection.select_one(
      "SELECT COUNT(DISTINCT portal_clazzes.id) AS active_classes, " +
      "COUNT(DISTINCT portal_learners.id) AS active_learners, " +
      "COUNT(DISTINCT portal_learners.student_id) AS active_students, " +
      "COUNT(DISTINCT portal_offerings.runnable_id, portal_offerings.runnable_type) AS active_runnables, " +
      "COUNT(DISTINCT portal_teachers.id) AS active_teachers, " +
      "COUNT(DISTINCT portal_schools.id) AS active_schools " +
      "FROM portal_teachers " +
      "INNER JOIN portal_teacher_clazzes ON portal_teacher_clazzes.teacher_id = portal_teachers.id " +
      "INNER JOIN portal_clazzes ON portal_clazzes.id = portal_teacher_clazzes.clazz_id " +
      "INNER JOIN portal_courses ON portal_courses.id = portal_clazzes.course_id " +
      "INNER JOIN portal_schools ON portal_schools.id = portal_courses.school_id " +
      "INNER JOIN portal_offerings ON portal_offerings.clazz_id = portal_clazzes.id " +
      "INNER JOIN portal_learners ON portal_learners.offering_id = portal_offerings.id " +
      "INNER JOIN report_learners ON report_learners.learner_id = portal_learners.id " +
      "WHERE report_learners.last_run is not null"
      )
    stats.merge!(result)

    result = ApplicationRecord.connection.select_one(
      "SELECT COUNT(DISTINCT portal_schools.id) AS class_schools, " +
      "COUNT(DISTINCT portal_teachers.id) AS class_teachers " +
      "FROM portal_teachers " +
      "INNER JOIN portal_teacher_clazzes ON portal_teacher_clazzes.teacher_id = portal_teachers.id " +
      "INNER JOIN portal_clazzes ON portal_clazzes.id = portal_teacher_clazzes.clazz_id " +
      "INNER JOIN portal_courses ON portal_courses.id = portal_clazzes.course_id " +
      "INNER JOIN portal_schools ON portal_schools.id = portal_courses.school_id"
      )
    stats.merge!(result)

    result = ApplicationRecord.connection.select_one(
      "SELECT COUNT(DISTINCT portal_schools.id) AS teacher_schools " +
      "FROM portal_teachers " +
      "INNER JOIN portal_school_memberships ON " +
        "(portal_teachers.id = portal_school_memberships.member_id AND portal_school_memberships.member_type = 'Portal::Teacher') " +
      "INNER JOIN portal_schools ON portal_schools.id = portal_school_memberships.school_id"
      )
    stats.merge!(result)

    respond_to do |format|
      format.json do
        render :json => stats
      end
    end
  end

  # Per the schoology docs: http://developers.schoology.com/app-platform/allowing-cookies
  def preflight
    session['preflighted'] = '1'
    render layout: 'basic'
  end

  # This is used by schoology. It is the first URL schoology opens when it is embedded as
  # an iframe in schoology.
  def auth_check
    send("check_#{params[:provider]}")
  end

  private

  def check_schoology
    provider = params[:provider]
    uid = nil
    if params[:realm] && params[:realm_id] && params[:realm] == "user"
      uid = params[:realm_id]
    end

    if request.referer && (host = URI(request.referer).host) && host !~ /concord\.org$/
      session[:schoology_host] = host
    else
      session.delete :schoology_host
    end

    generic_check(provider, uid)
  end

  # Checks if the current user is the same one as provided.
  # If not, authenticate the user through the provider.
  def generic_check(provider, uid=nil)
    if uid
      if current_user == (Authentication.find_by_provider_and_uid(provider, uid).user rescue nil)
        redirect_to(root_path)
        return
      end
    end
    redirect_to "/users/auth/#{provider}"
  end

  # from https://stackoverflow.com/a/61552216
  def get_full_path_to_asset(filename)
    manifest_file = Rails.application.assets_manifest.assets[filename]
    if manifest_file
      File.join(Rails.application.assets_manifest.directory, manifest_file)
    else
      Rails.application.assets&.[](filename)&.filename
    end
  end

end
