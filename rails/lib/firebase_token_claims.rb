require 'digest/md5'

# The identity every Firebase custom token the portal mints for a user carries. The
# browser's tokens (API::V1::JwtController#firebase) and the Researcher Dashboard runner's
# (ResearcherDashboard::RunnerTokens) must name the same Firebase principal, since the
# rules in both projects key on uid, platform_id and platform_user_id.
module FirebaseTokenClaims
  # A Firebase uid is 1 to 36 characters and unique across portals; MD5 of the
  # portal-qualified user URL is 32.
  def self.uid(user)
    Digest::MD5.hexdigest(user_id(user))
  end

  def self.user_id(user)
    APP_CONFIG[:site_url].sub(/\/$/, '') + Rails.application.routes.url_helpers.polymorphic_path(user)
  end

  # Firebase rules read these from the "claims" sub-object.
  def self.identity(user)
    { platform_id: APP_CONFIG[:site_url], platform_user_id: user.id, user_id: user_id(user) }
  end
end
