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
    # Decode header and payload without verification (single decode)
    unverified = JWT.decode(token, nil, false)
    unverified_payload = unverified[0]
    header = unverified[1]
    kid = header['kid']
    token_aud = unverified_payload['aud']
    token_iss = unverified_payload['iss']
    token_sub = unverified_payload['sub']
    token_exp = unverified_payload['exp']
    Rails.logger.info("GoogleOidcVerifier: verifying token kid=#{sanitize_log(kid)} alg=#{sanitize_log(header['alg'])}")
    Rails.logger.debug("GoogleOidcVerifier: token claims iss=#{sanitize_log(token_iss)} sub=#{sanitize_log(token_sub)} aud=#{sanitize_log(token_aud)} exp=#{token_exp} (#{Time.at(token_exp).utc rescue 'invalid'})")

    # Find the matching public key
    key = find_key(kid)
    unless key
      Rails.logger.warn("GoogleOidcVerifier: no public key found for kid=#{kid}, available kids=#{cached_kids.join(',')}")
      raise Error, "Could not find public key for kid=#{kid}"
    end
    Rails.logger.info("GoogleOidcVerifier: found public key for kid=#{kid}")

    # Verify the token
    expected_audience = APP_CONFIG[:site_url]
    aud_match = Array(token_aud).include?(expected_audience)
    Rails.logger.info("GoogleOidcVerifier: expected_audience=#{expected_audience} token_audience=#{sanitize_log(token_aud)} match=#{aud_match}")
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

    Rails.logger.info("GoogleOidcVerifier: token verified successfully sub=#{payload['sub']}")
    payload
  rescue JWT::ExpiredSignature => e
    Rails.logger.warn("GoogleOidcVerifier: token expired - exp=#{token_exp} (#{Time.at(token_exp).utc rescue 'invalid'}) now=#{Time.now.utc}")
    raise Error, e.message
  rescue JWT::InvalidIssuerError => e
    Rails.logger.warn("GoogleOidcVerifier: invalid issuer - token_iss=#{token_iss} valid_issuers=#{VALID_ISSUERS}")
    raise Error, e.message
  rescue JWT::InvalidAudError => e
    Rails.logger.warn("GoogleOidcVerifier: audience mismatch - token_aud=#{token_aud} expected_aud=#{APP_CONFIG[:site_url]}")
    raise Error, "Invalid audience: #{e.message}"
  rescue JWT::DecodeError => e
    Rails.logger.warn("GoogleOidcVerifier: decode error - #{e.class}: #{e.message}")
    raise Error, e.message
  end

  private

  def self.sanitize_log(value)
    str = value.to_s[0, 100]
    str.gsub(/[\r\n]/, ' ')
  end

  def self.find_key(kid)
    keys = cached_keys
    key = key_for_kid(keys, kid)
    return key if key

    # Key not found — try refreshing once (handles key rotation)
    Rails.logger.info("GoogleOidcVerifier: kid=#{kid} not in cache, refreshing JWKS")
    keys = fetch_keys!
    key_for_kid(keys, kid)
  end

  def self.cached_kids
    (@jwks_keys || []).map { |k| k[:kid] || k['kid'] }
  end

  def self.key_for_kid(keys, kid)
    keys&.find { |k| k[:kid] == kid || k['kid'] == kid }&.then { |jwk_data| JWT::JWK.new(jwk_data).public_key }
  end

  def self.cached_keys
    if @jwks_keys && @jwks_fetched_at && (Time.now - @jwks_fetched_at) < JWKS_CACHE_TTL
      age = (Time.now - @jwks_fetched_at).round
      Rails.logger.info("GoogleOidcVerifier: using cached JWKS (age=#{age}s, keys=#{@jwks_keys.size})")
      return @jwks_keys
    end

    Rails.logger.info("GoogleOidcVerifier: JWKS cache miss or expired, fetching fresh keys")
    fetch_keys!
  end

  def self.fetch_keys!
    uri = URI(JWKS_URI)
    Rails.logger.info("GoogleOidcVerifier: fetching JWKS from #{JWKS_URI}")
    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      if @jwks_keys
        @jwks_fetched_at = Time.now
        Rails.logger.warn("GoogleOidcVerifier: JWKS refresh failed (HTTP #{response.code}), serving #{@jwks_keys.size} stale keys")
        return @jwks_keys
      end
      raise Error, "Failed to fetch JWKS: HTTP #{response.code}"
    end

    jwks_data = JSON.parse(response.body)
    @jwks_keys = jwks_data['keys']
    @jwks_fetched_at = Time.now
    kids = @jwks_keys.map { |k| k[:kid] || k['kid'] }
    Rails.logger.info("GoogleOidcVerifier: JWKS fetched successfully, #{@jwks_keys.size} keys: #{kids.join(', ')}")
    @jwks_keys
  rescue StandardError => e
    if @jwks_keys
      @jwks_fetched_at = Time.now
      Rails.logger.warn("GoogleOidcVerifier: JWKS refresh failed (#{e.class}: #{e.message}), serving #{@jwks_keys.size} stale keys")
      return @jwks_keys
    end
    Rails.logger.error("GoogleOidcVerifier: JWKS fetch failed with no cache available: #{e.class}: #{e.message}")
    raise Error, "Failed to fetch JWKS: #{e.message}"
  end
end
