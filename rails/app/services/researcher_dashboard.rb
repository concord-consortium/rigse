module ResearcherDashboard
  # Where this deployment's dashboard app is served from, and whether it exists at all.
  #
  # Gating on the URL's presence rather than on a feature flag, which is how the portal
  # already gates the researcher report links (`navigation_helper.rb`,
  # `ENV['REPORT_SERVER_REPORTS_URL'].present?`). An environment with nowhere to send a
  # researcher should not offer to send them anywhere, and that is the same condition.
  def self.url
    ENV['RESEARCHER_DASHBOARD_URL'].presence
  end

  def self.enabled?
    url.present?
  end
end
