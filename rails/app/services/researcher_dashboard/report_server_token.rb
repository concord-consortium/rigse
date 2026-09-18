module ResearcherDashboard
  # Obtains the report-server API token a researcher's Analyze Class MicroVM pulls with.
  #
  # The VM used to pull as a shared account that is a portal site admin, so one
  # credential inside it could read every class at Concord. It pulls as the requesting
  # researcher instead, which makes report-server's scoping agree with the portal's own
  # check: `get_allowed_project_ids` returns that researcher's projects rather than
  # `:all`.
  #
  # Minted per VM launch, with the researcher's previous one revoked in the same call,
  # so exactly one is live and a copy that leaked from an earlier VM stops working.
  # `revoke` is what the VM's terminate hook reaches, so the credential dies with the VM.
  #
  # The portal authenticates as a service here, not as a user, and sends the user
  # information it is authoritative about. It has already applied
  # `can_be_researcher_for_clazz?` before asking; report-server does not re-derive that.
  class ReportServerToken
    class Error < StandardError; end
    class NotConfigured < Error; end

    def self.mint(user:)
      new(user).request(:post)
    end

    def self.revoke(user:)
      new(user).request(:delete)
    end

    def initialize(user)
      @user = user
    end

    def request(method)
      raise NotConfigured, "REPORT_SERVER_URL is not set" if base_url.blank?
      raise NotConfigured, "PORTAL_SERVICE_SECRET is not set" if secret.blank?

      response = HTTParty.send(
        method,
        "#{base_url.chomp('/')}/api/v1/dashboard-tokens",
        headers: {
          "Authorization" => "Bearer #{secret}",
          "Content-Type" => "application/json"
        },
        body: payload.to_json,
        timeout: 10
      )

      unless response.success?
        raise Error, "report-server refused the dashboard token request: #{response.code}"
      end

      response.parsed_response
    end

    private

    # The role flags decide what report-server lets this token read, and the portal is
    # the authority on them. Sending them keeps them current: report-server's own copy
    # is only as fresh as this user's last sign-in there, which for a researcher who
    # only meets it through the VM may be never.
    def payload
      {
        portal_user_id: @user.id,
        portal_server: URI.parse(APP_CONFIG[:site_url]).host,
        login: @user.login,
        first_name: @user.first_name,
        last_name: @user.last_name,
        email: @user.email,
        is_admin: @user.has_role?('admin'),
        is_project_admin: @user.admin_for_projects.any?,
        is_project_researcher: @user.researcher_for_projects.any?
      }
    end

    def base_url
      ENV['REPORT_SERVER_URL']
    end

    def secret
      ENV['PORTAL_SERVICE_SECRET']
    end
  end
end
