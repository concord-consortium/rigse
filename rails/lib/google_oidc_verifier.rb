require 'jwt'
require 'net/http'
require 'json'

# Custom Google OIDC token verifier. Google provides the google-id-token gem for
# this purpose, but it pulls in large dependencies (google-apis-core, etc.) and
# the verification logic is straightforward: fetch Google's public JWKS, match
# the key by `kid`, and let the ruby-jwt gem handle RS256 signature and claim
# validation. Keeping this in-house avoids the extra dependency surface while
# giving us full control over caching, error handling, and clock-skew settings.
module GoogleOidcVerifier
  class Error < StandardError; end

  JWKS_URI = 'https://www.googleapis.com/oauth2/v3/certs'.freeze
  VALID_ISSUERS = ['accounts.google.com', 'https://accounts.google.com'].freeze
  JWKS_CACHE_TTL = 3600 # 1 hour
  CLOCK_SKEW = 30 # seconds

  # Verifies a Google OIDC token and returns the decoded payload.
  # Raises GoogleOidcVerifier::Error on any failure.
  def self.verify(token)
    # Decode header to get kid (without verification)
    header = JWT.decode(token, nil, false)[1]
    kid = header['kid']

    # Find the matching public key
    key = find_key(kid)
    raise Error, "Could not find public key for kid=#{kid}" unless key

    # Verify the token
    expected_audience = APP_CONFIG[:site_url]
    decoded = JWT.decode(
      token,
      key,
      true,
      {
        algorithm: 'RS256',
        verify_iss: true,
        iss: VALID_ISSUERS,
        verify_aud: true,
        aud: expected_audience,
        exp_leeway: CLOCK_SKEW
      }
    )
    payload = decoded[0]

    # Additional issuer check (JWT gem checks iss is IN the array)
    unless VALID_ISSUERS.include?(payload['iss'])
      raise Error, "Invalid issuer: #{payload['iss']}"
    end

    payload
  rescue JWT::ExpiredSignature => e
    raise Error, e.message
  rescue JWT::InvalidIssuerError => e
    raise Error, e.message
  rescue JWT::InvalidAudError => e
    raise Error, "Invalid audience: #{e.message}"
  rescue JWT::DecodeError => e
    raise Error, e.message
  end

  private

  def self.find_key(kid)
    keys = cached_keys
    key = key_for_kid(keys, kid)
    return key if key

    # Key not found — try refreshing once (handles key rotation)
    keys = fetch_keys!
    key_for_kid(keys, kid)
  end

  def self.key_for_kid(keys, kid)
    keys&.find { |k| k[:kid] == kid || k['kid'] == kid }&.then { |jwk_data| JWT::JWK.new(jwk_data).public_key }
  end

  def self.cached_keys
    if @jwks_keys && @jwks_fetched_at && (Time.now - @jwks_fetched_at) < JWKS_CACHE_TTL
      return @jwks_keys
    end

    fetch_keys!
  end

  def self.fetch_keys!
    uri = URI(JWKS_URI)
    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      if @jwks_keys
        # Use stale cache rather than rejecting all requests.
        # Update fetched_at so we don't retry on every request during an outage.
        @jwks_fetched_at = Time.now
        Rails.logger.warn("GoogleOidcVerifier: JWKS refresh failed (HTTP #{response.code}), serving stale keys")
        return @jwks_keys
      end
      raise Error, "Failed to fetch JWKS: HTTP #{response.code}"
    end

    jwks_data = JSON.parse(response.body)
    @jwks_keys = jwks_data['keys']
    @jwks_fetched_at = Time.now
    @jwks_keys
  rescue StandardError => e
    if @jwks_keys
      # Update fetched_at so we don't retry on every request during an outage.
      @jwks_fetched_at = Time.now
      Rails.logger.warn("GoogleOidcVerifier: JWKS refresh failed (#{e.message}), serving stale keys")
      return @jwks_keys
    end
    raise Error, "Failed to fetch JWKS: #{e.message}"
  end
end
