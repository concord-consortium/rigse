# Portal tokens shaped like the ones rigse issues, for specs of where such a token reaches.
module PortalTokenHelper
  # As oidc_mint issues it.
  def self.minted_token(user, oidc_client_id: 1)
    SignedJwt.create_portal_token(user, {
      minted_via_oidc_client_id: oidc_client_id,
      minted_for: 'spec',
      scope: TokenCapabilities::PORTAL_API
    })
  end

  def self.unmarked_portal_api_token(user)
    SignedJwt.create_portal_token(user, { scope: TokenCapabilities::PORTAL_API })
  end

  # As /oauth/token issues it; `capabilities` nil is an unscoped token.
  def self.access_token(user, capabilities:, context: nil)
    SignedJwt.create_access_token(user, client_id: 'spec', capabilities: capabilities, context: context,
                                  audiences: [APP_CONFIG[:site_url]], expires_in: 600)
  end
end
