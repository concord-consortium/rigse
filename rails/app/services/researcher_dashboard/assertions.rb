module ResearcherDashboard
  # The two short-lived assertions rigse signs for other services. Both travel service to
  # service and never reach a browser, which is why the role flags are allowed here and
  # never in the launch token.
  module Assertions
    # Long enough to survive a cold function start and the one call that follows it.
    TTL = 120

    # Exchanged at report-server for the researcher's own API token. Carries the fields
    # report-server's user row requires, and a jti so report-server can refuse a replay.
    def self.report_server(user:, clazz:)
      SignedJwt.create_portal_token(user, {
        user_type: 'researcher',
        scope_kind: 'class',
        scope_id: clazz.id,
        jti: SecureRandom.uuid,
        portal_user_id: user.id,
        portal_server: URI.parse(APP_CONFIG[:site_url]).host,
        login: user.login,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        is_admin: user.has_role?('admin'),
        is_project_admin: user.admin_for_projects.any?,
        is_project_researcher: user.researcher_for_projects.any?
      }, TTL, aud: SignedJwt::AUD_REPORT_SERVER)
    end

    # Presented to the report-service function to queue work, in place of its shared bearer.
    def self.report_service_functions(user:)
      SignedJwt.create_portal_token(user, {}, TTL, aud: SignedJwt::AUD_REPORT_SERVICE_FUNCTIONS)
    end
  end
end
