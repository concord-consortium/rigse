require 'digest/md5'

# The identity every Firebase custom token the portal mints carries.
#
# Two callers mint these: API::V1::JwtController#firebase for browsers, and
# ResearcherDashboard::RunnerToken for the Analyze Class MicroVMs. They have to name
# the same Firebase principal for the same portal user, since a token whose uid or
# platform_user_id disagreed would read and write another principal's documents, and
# the Firebase rules in both projects key on both values.
class FirebaseTokenClaims
  # Firebase uids are 1 to 36 characters and must be unique across all portals; MD5 of
  # the portal-qualified user URL yields 32.
  def self.uid(user)
    Digest::MD5.hexdigest(user_id(user))
  end

  def self.user_id(user)
    site_url_without_trailing_slash = APP_CONFIG[:site_url].sub(/\/$/, '')
    site_url_without_trailing_slash + Rails.application.routes.url_helpers.polymorphic_path(user)
  end

  # Firebase auth rules expect all the claims to be in a sub-object named "claims";
  # this is what every caller starts that sub-object from.
  def self.identity(user)
    {
      platform_id: APP_CONFIG[:site_url],
      platform_user_id: user.id,
      user_id: user_id(user)
    }
  end
end
