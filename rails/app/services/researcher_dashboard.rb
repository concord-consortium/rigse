# Where this deployment's Researcher Dashboard app lives, whether it is on, and the URL
# that launches it into a scope.
#
# On only when there is somewhere to send a researcher and a key to sign the launch
# with, so an environment missing either offers no link rather than one that fails.
module ResearcherDashboard
  # Covers a session's rigse calls (Firebase sessions outlive it); as ExternalReport::ReportTokenValidFor.
  LAUNCH_TOKEN_TTL = 2.hours.to_i

  def self.url
    ENV['RESEARCHER_DASHBOARD_URL'].presence
  end

  def self.enabled?
    url.present? && PortalSigningKey.configured?
  end

  # token is the only parameter added, and never carries role flags, because this URL
  # ends up in history, screenshots and pasted links.
  def self.launch_url(user:, clazz:)
    token = SignedJwt.create_portal_token(
      user,
      { user_type: 'researcher', scope_kind: 'class', scope_id: clazz.id },
      LAUNCH_TOKEN_TTL,
      aud: SignedJwt::AUD_RESEARCHER_DASHBOARD
    )
    uri = URI.parse(url)
    uri.query = Rack::Utils.build_query(Rack::Utils.parse_query(uri.query).merge('token' => token))
    uri.to_s
  end
end
