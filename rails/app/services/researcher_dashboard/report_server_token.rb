module ResearcherDashboard
  # Revokes the report-server API token a researcher's Analyze Class MicroVM pulled with,
  # so the credential dies with the VM rather than living until their next launch.
  #
  # Minting belongs to the report-service launch function rather than here: only the
  # branch that creates a VM may mint, and only that function knows whether it is
  # creating one. It calls report-server directly, presenting the signed claim from
  # ReportServerAssertion. Revocation runs from the portal, against the same endpoint
  # and the same shared secret.
  class ReportServerToken
    class Error < StandardError; end
    class NotConfigured < Error; end

    def self.revoke(user:)
      new(user).revoke
    end

    def initialize(user)
      @user = user
    end

    def revoke
      raise NotConfigured, "REPORT_SERVER_URL is not set" if base_url.blank?
      raise NotConfigured, "PORTAL_SERVICE_SECRET is not set" if secret.blank?

      response = HTTParty.delete(
        "#{base_url.chomp('/')}/api/v1/dashboard-tokens",
        headers: {
          "Authorization" => "Bearer #{secret}",
          "Content-Type" => "application/json"
        },
        body: PortalUserInfo.for(@user).to_json,
        timeout: 10
      )

      unless response.success?
        raise Error, "report-server refused the dashboard token revocation: #{response.code}"
      end

      response.parsed_response
    end

    private

    def base_url
      ENV['REPORT_SERVER_URL']
    end

    def secret
      ENV['PORTAL_SERVICE_SECRET']
    end
  end
end
