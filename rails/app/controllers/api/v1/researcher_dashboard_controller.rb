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
    error(e.message, 502)
  rescue ResearcherDashboard::RunPackage::NotConfigured,
         ResearcherDashboard::ReportServerAssertion::NotConfigured => e
    error(e.message, 500)
  end

  private

  def package_params
    package = params[:package]
    return nil unless package.respond_to?(:[])

    name, version, checksum = %w[name version checksum].map { |key| package[key].to_s }
    return nil if name.blank? || version.blank? || checksum.blank?

    { name: name, version: version, checksum: checksum }
  end
end
