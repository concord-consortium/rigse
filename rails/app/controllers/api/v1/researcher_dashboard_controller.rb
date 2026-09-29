# The three calls the Researcher Dashboard app makes with the access token it obtained
# through the OAuth code flow. The token carries the scope it was issued for in its
# `context` claim, so no route names a class and no path can disagree with the scope.
#
# A capability is a ceiling and never a grant, so the researcher gate runs on every call:
# a token lives two hours and a researcher's access can be withdrawn inside one.
class API::V1::ResearcherDashboardController < API::APIController
  # Bearer-only: no session is read, so there is no session for a forged request to ride.
  skip_before_action :verify_authenticity_token
  # A body is read as exactly what was sent, so Rails' copy of it under the controller's
  # name would only be a second, looser reading.
  wrap_parameters false

  # What each action asks of the scope in the token. Capabilities are flat, so a client
  # that may run packages is configured with the read capability as well.
  ACTION_CAPABILITIES = {
    scope: TokenCapabilities::CLASS_RESEARCHER_READ,
    refresh_profile: TokenCapabilities::CLASS_RESEARCHER_READ,
    run_package: TokenCapabilities::CLASS_RESEARCHER_RUN
  }.freeze

  # API::APIController accepts portal-api on every action; none of these does, so a
  # service-minted token is refused here as it is everywhere outside the wider API.
  accepts_no_token_capabilities
  ACTION_CAPABILITIES.each { |action, capability| accepts_token_capability capability, only: action }

  before_action :require_api_user!
  before_action :require_scoped_credential
  before_action :authorize_scope

  rescue_from ResearcherDashboard::Refusal do |e|
    error(e.message, e.status, e.details)
  end
  rescue_from ResearcherDashboard::Settings::NotConfigured do |e|
    error("The Researcher Dashboard is not fully configured: #{e.message}", 503)
  end

  # GET /api/v1/researcher_dashboard/scope
  def scope
    facts = ResearcherDashboard::Scope.new(@clazz)
    render json: {
      # The discriminator scope.json carries, so a second scope kind adds a shape here
      # rather than a second set of routes.
      kind: TokenCapabilities::CLASS_CONTEXT,
      id: @clazz.id,
      name: @clazz.name,
      class_hash: @clazz.class_hash,
      # Whose dashboard this is: the app keys its runner and result listeners by it.
      platform_user_id: current_user.id,
      teachers: facts.teachers,
      cohorts: facts.cohorts.map { |c| { id: c.id, name: c.name } },
      project_ids: facts.project_ids,
      assignment_fingerprint: facts.fingerprint,
      assignments: facts.assignments
    }
  end

  # POST /api/v1/researcher_dashboard/refresh_profile
  def refresh_profile
    render status: 202, json: ResearcherDashboard::ProfileRefresh.call(user: current_user, clazz: @clazz)
  end

  # POST /api/v1/researcher_dashboard/run_package
  def run_package
    packages = ResearcherDashboard::RunRequest.parse(request.raw_post)
    render status: 202, json: ResearcherDashboard::RunPackage.call(
      user: current_user, clazz: @clazz, packages: packages, access_token: PortalBearer.raw_token(request.headers['Authorization'])
    )
  end

  private

  # An unscoped credential passes every capability check, so without this a portal session
  # or an HS256 token would reach endpoints that mint Firebase runner tokens and that skip
  # the CSRF check because they are meant to be reached only by a bearer.
  def require_scoped_credential
    return if TokenScope.scoped?
    error('These endpoints accept only a Researcher Dashboard access token', 401)
  end

  def authorize_scope
    context = Current.token_context
    unless context && context['type'] == TokenCapabilities::CLASS_CONTEXT
      return error('This token is not bound to a class', 403)
    end
    @clazz = Portal::Clazz.find_by(id: context['id'])
    return error('The class this token was issued for no longer exists', 404) unless @clazz
    # Names the one capability this action needs; the global check passes on any declared one.
    require_token_capability!(ACTION_CAPABILITIES.fetch(action_name.to_sym), @clazz)
    unless current_user.can_be_researcher_for_clazz?(@clazz)
      error('You do not have access to this class as a researcher', 403)
    end
  end

  # A capability refusal answers in the same envelope as every other refusal here.
  def token_capability_denied(exception = nil)
    error(exception&.message || 'This token may not be used here', 403)
  end
end
