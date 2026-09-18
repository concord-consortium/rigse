module ResearcherDashboard
  # The signed claim the portal hands the report-service launch function, which relays it
  # to report-server in exchange for the requesting researcher's own API token.
  #
  # Why a signed claim rather than letting the function hold the shared secret: that
  # secret is an admin-scope lever, not merely a minting credential. report-server's mint
  # endpoint reads the role flags from whoever calls it and persists them onto the user
  # row, and `get_allowed_project_ids` returns every project for a site admin, so a holder
  # of the secret can mint a token for any portal user with any flags. Signing binds the
  # claim to one researcher carrying the flags the portal actually computed, so the
  # function can relay it without being able to re-aim it.
  #
  # HS256, because the secret stays between the portal and report-server and the function
  # relays the assertion without reading it. An HMAC verifier is also a minter, so if
  # anything downstream ever needs to verify this rather than pass it along, it has to
  # become RS256 with a portal keypair first.
  class ReportServerAssertion
    class Error < StandardError; end
    class NotConfigured < Error; end

    ALGORITHM = "HS256".freeze
    AUDIENCE = "report-server".freeze
    # Long enough to survive a cold function start and the one call that follows it,
    # short enough that a copy is worthless by the time anyone finds it in a log.
    TTL = 120

    def self.mint(user:)
      new(user).mint
    end

    def initialize(user)
      @user = user
    end

    def mint
      raise NotConfigured, "PORTAL_SERVICE_SECRET is not set" if secret.blank?

      now = Time.now.to_i
      claims = PortalUserInfo.for(@user).merge(
        iss: URI.parse(APP_CONFIG[:site_url]).host,
        aud: AUDIENCE,
        iat: now,
        exp: now + TTL,
        jti: SecureRandom.uuid
      )

      JWT.encode(claims, secret, ALGORITHM)
    end

    private

    def secret
      ENV['PORTAL_SERVICE_SECRET']
    end
  end
end
