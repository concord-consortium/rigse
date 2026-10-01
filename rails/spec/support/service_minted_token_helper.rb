# Portal JWTs shaped like the ones oidc_mint issues, for specs of where such a token reaches.
module ServiceMintedTokenHelper
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
end
