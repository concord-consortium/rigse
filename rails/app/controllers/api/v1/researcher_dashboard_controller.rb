class API::V1::ResearcherDashboardController < API::APIController

  # Asks report-service to run a package against a class, on the researcher's behalf.
  #
  # This is the only gate on which classes a researcher may analyze, so it runs before
  # anything is minted and a refusal never reaches report-service. The runner tokens go
  # straight to report-service and only the result document's path comes back, which is
  # what keeps the runner claim out of a browser.
  def run_package
    # Before the class is looked up, so an anonymous caller cannot tell a class that
    # exists from one that does not by the difference between 403 and 404.
    return error("You must be logged in to use this endpoint", 401) unless current_user

    clazz = Portal::Clazz.find_by_id(params[:class_id])
    return error("A class with the requested class_id does not exist", 404) unless clazz

    unless current_user.can_be_researcher_for_clazz?(clazz)
      return error("You do not have access to the requested class as a researcher", 403)
    end

    package = package_params
    return error("package must carry name, version and checksum") if package.nil?
    # The package name is the result document's id, so a name with a slash would write a
    # nested collection instead. The runner refuses this too; refusing here as well means
    # a bad name costs no VM.
    if package[:name].include?("/") || [".", ".."].include?(package[:name])
      return error("package name must be a single path segment")
    end

    apps = Array(params[:firebase_apps]).map(&:to_s).reject(&:blank?)
    return error("firebase_apps must name at least one Firebase app") if apps.empty?

    project = params[:firebase_project].to_s
    return error("firebase_project is required") if project.blank?
    # Without a class token for its own project the VM cannot write the class or result
    # documents, and refuses the run after it has been launched.
    unless apps.include?(project)
      return error("firebase_apps must include firebase_project (#{project})")
    end

    result = ResearcherDashboard::RunPackage.call(
      user: current_user, clazz: clazz, package: package,
      firebase_project: project, firebase_apps: apps
    )
    render json: result

  rescue ResearcherDashboard::RunnerToken::NotAuthorized => e
    error(e.message, 403)
  rescue ResearcherDashboard::RunPackage::Refused => e
    # A busy VM is passed through as itself. Everything else upstream is a bad gateway
    # from the caller's side, since there is nothing they can do about it.
    error(e.message, e.status.to_i == 409 ? 409 : 502)
  rescue ResearcherDashboard::RunPackage::NotConfigured,
         ResearcherDashboard::ReportServerAssertion::NotConfigured => e
    error(e.message, 500)
  end

  # What the dashboard app shows above the analyses: which class this is, whose it is, and
  # what was assigned in it. Read-only, and gated by the same class check as everything
  # else here, so the app cannot use it to enumerate classes.
  def clazz
    return error("You must be logged in to use this endpoint", 401) unless current_user

    clazz = Portal::Clazz.find_by_id(params[:id])
    return error("A class with the requested class_id does not exist", 404) unless clazz

    unless current_user.can_be_researcher_for_clazz?(clazz)
      return error("You do not have access to the requested class as a researcher", 403)
    end

    render json: {
      id: clazz.id,
      name: clazz.name,
      class_hash: clazz.class_hash,
      # Whose dashboard this is. The researcher status document is keyed by it, and the app
      # should not have to take it apart from a token to know which document is its own.
      platform_user_id: current_user.id,
      teacher_names: clazz.teachers.map { |t| "#{t.user.first_name} #{t.user.last_name}" },
      cohort_names: clazz.teachers.flat_map { |t| t.cohorts.map(&:name) }.uniq,
      assignments: assignments_for(clazz)
    }
  end

  private

  # One entry per assigned runnable, with the platform the analysis packages match on.
  # `tools.source_type` is what the portal already uses to tell an Activity Player
  # assignment from a CLUE one (`default_report_service.rb:6`), and a runnable with no
  # tool has no source_type rather than a default, which is reported as nil rather than
  # guessed: a package matching on platform should skip it, not mis-handle it.
  def assignments_for(clazz)
    clazz.offerings.map do |offering|
      runnable = offering.runnable
      {
        id: offering.id,
        runnable_id: runnable&.id,
        name: runnable&.name,
        platform: runnable.respond_to?(:tool) ? runnable.tool&.source_type : nil
      }
    end
  end

  def package_params
    package = params[:package]
    return nil unless package.respond_to?(:[])

    name, version, checksum = %w[name version checksum].map { |key| package[key].to_s }
    return nil if name.blank? || version.blank? || checksum.blank?

    { name: name, version: version, checksum: checksum }
  end
end
