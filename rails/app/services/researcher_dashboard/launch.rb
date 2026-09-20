module ResearcherDashboard
  # The URL a researcher is sent to when they click Analyze on a class.
  #
  # The same shape the class dashboard already launches with (`ExternalReport#url_for_class`):
  # a short-lived OAuth grant for this user against a `Client` record, carried in the query
  # with the API url of the class it is for. The app exchanges the grant for nothing; it
  # holds it as its bearer for the portal's own endpoints and nothing else. No runner token
  # is ever in this URL, which is the property the Credentials section rests on.
  class Launch
    class Error < StandardError; end
    class NotConfigured < Error; end

    # The Client is created through the admin UI, so its secret is never in the repository
    # nor in a migration that replays into every environment. What the code needs is a way
    # to find it, and a fixed name is the least configuration that does: an environment
    # with a dashboard URL and no Client of this name is misconfigured, and says so rather
    # than launching a researcher at a page that cannot authenticate.
    CLIENT_NAME = 'researcher-dashboard'.freeze

    # The first page of the app, and today the only one. The app switches on `page`, so the
    # value is part of the launch contract rather than a path.
    PAGE = 'analyze-class'.freeze

    def self.url_for(clazz:, user:, protocol:, host:)
      new(clazz: clazz, user: user, protocol: protocol, host: host).url
    end

    def initialize(clazz:, user:, protocol:, host:)
      @clazz = clazz
      @user = user
      @protocol = protocol
      @host = host
    end

    def url
      raise NotConfigured, 'RESEARCHER_DASHBOARD_URL is not set' unless ResearcherDashboard.enabled?
      raise NotConfigured, "no Client named #{CLIENT_NAME}" if client.nil?

      add_query_params(ResearcherDashboard.url, launch_params)
    end

    private

    attr_reader :clazz, :user, :protocol, :host

    def client
      @client ||= Client.find_by(name: CLIENT_NAME)
    end

    def launch_params
      grant = client.updated_grant_for(user, ExternalReport::ReportTokenValidFor)
      {
        page: PAGE,
        class: Rails.application.routes.url_helpers.api_v1_class_url(
          clazz.id, protocol: protocol, host: host
        ),
        token: grant.access_token,
        # The app shows a researcher's view of someone else's class, which is a different
        # page from a teacher's, and the portal endpoints it calls branch on this too.
        researcher: 'true'
      }
    end

    # Merged into whatever the configured URL already carries, so a deployment whose
    # index.html needs its own query parameters keeps them.
    def add_query_params(url, params)
      uri = URI.parse(url)
      query = Rack::Utils.parse_query(uri.query)
      uri.query = query.merge(params.stringify_keys).to_query
      uri.to_s
    end
  end
end
