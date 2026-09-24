# The calls the Researcher Dashboard app makes with its launch token.
#
# Only a launch token opens them, because only a launch token carries the scope they act
# on; a session, an HS256 portal token or an AccessGrant authenticates but names no scope.
# The scope says what the launch was for and never authorizes on its own, so the researcher
# gate runs on every call, before anything is read, minted or sent.
class API::V1::ResearcherDashboardController < API::APIController
  # Bearer-only: no session is read, so there is no session for a forged request to ride.
  skip_before_action :verify_authenticity_token
  # A body is read as exactly what was sent, so Rails' copy of it under the controller's
  # name would only be a second, looser reading.
  wrap_parameters false

  before_action :require_dashboard_enabled
  before_action :authorize_scope
  before_action :require_path_matches_scope, only: [:clazz, :refresh_profile]

  rescue_from ResearcherDashboard::Refusal do |e|
    error(e.message, e.status, e.details)
  end
  rescue_from ResearcherDashboard::Settings::NotConfigured do |e|
    error("The Researcher Dashboard is not fully configured: #{e.message}", 503)
  end
  rescue_from ActionDispatch::Http::Parameters::ParseError do
    error('The body must be a JSON object', 400)
  end

  # GET /api/v1/researcher_dashboard/classes/:id
  def clazz
    scope = ResearcherDashboard::Scope.new(@clazz)
    render json: {
      id: @clazz.id,
      name: @clazz.name,
      class_hash: @clazz.class_hash,
      # Whose dashboard this is: the app keys its runner and result listeners by it.
      platform_user_id: @user.id,
      teachers: scope.teachers,
      cohorts: scope.cohorts.map { |c| { id: c.id, name: c.name } },
      project_ids: scope.project_ids,
      assignment_fingerprint: scope.fingerprint,
      assignments: scope.assignments
    }
  end

  # POST /api/v1/researcher_dashboard/classes/:id/refresh_profile
  def refresh_profile
    render status: 202, json: ResearcherDashboard::ProfileRefresh.call(user: @user, clazz: @clazz)
  end

  # POST /api/v1/researcher_dashboard/run_package
  def run_package
    packages = ResearcherDashboard::RunRequest.parse(request.raw_post)
    render status: 202, json: ResearcherDashboard::RunPackage.call(
      user: @user, clazz: @clazz, packages: packages, launch_token: @launch_token
    )
  end

  private

  def require_dashboard_enabled
    head :not_found unless ResearcherDashboard.enabled?
  end

  def authorize_scope
    begin
      @user, _role = check_for_auth_token(params, aud: SignedJwt::AUD_RESEARCHER_DASHBOARD)
    rescue ActionDispatch::Http::Parameters::ParseError
      raise
    rescue StandardError => e
      # SignedJwt::Error, JWT::ExpiredSignature, and check_for_auth_token's own refusals.
      return error("Launch the Researcher Dashboard again from the portal (#{e.message})", 401)
    end
    if Current.token_scope_kind.nil? && Current.token_scope_id.nil?
      return error('This endpoint accepts only a Researcher Dashboard launch token', 401)
    end
    unless Current.token_scope_kind == 'class'
      return error("This token's scope kind (#{Current.token_scope_kind.inspect}) is not supported", 403)
    end
    @clazz = Portal::Clazz.find_by_id(Current.token_scope_id)
    return error('The class this token was issued for no longer exists', 404) unless @clazz
    unless @user.can_be_researcher_for_clazz?(@clazz)
      return error('You do not have access to this class as a researcher', 403)
    end
    # Forwarded unchanged to report-server's resolve, which applies its visibility rule to
    # the same researcher. Never logged and never returned.
    @launch_token = extract_bearer_token(request.headers['Authorization'])
  end

  def require_path_matches_scope
    unless Integer(params[:id], 10, exception: false) == @clazz.id
      error('The requested class is not the class this token was issued for', 403)
    end
  end
end
