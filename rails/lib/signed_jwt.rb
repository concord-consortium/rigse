module SignedJwt

  require 'jwt'

  # Seconds to backdate the issued-at (iat) claim in Firebase JWTs,
  # compensating for clock skew between this server and Google.
  CLOCK_SKEW_ALLOWANCE = 30

  class Error < StandardError
  end

  # The audiences an RS256 portal token can carry. Each keeps its claim set and its reach
  # apart from the others; no rigse endpoint accepts the two service audiences.
  AUD_RESEARCHER_DASHBOARD     = 'researcher-dashboard'.freeze
  AUD_REPORT_SERVER            = 'report-server'.freeze
  AUD_REPORT_SERVICE_FUNCTIONS = 'report-service-functions'.freeze
  AUDIENCES = [AUD_RESEARCHER_DASHBOARD, AUD_REPORT_SERVER, AUD_REPORT_SERVICE_FUNCTIONS].freeze

  # Without aud: the legacy HS256 portal token. With aud: an RS256 token for that
  # audience, signed by the environment's key and carrying its kid.
  def self.create_portal_token(user, claims={}, expires_in=3600, aud: nil)
    if aud && !AUDIENCES.include?(aud)
      raise SignedJwt::Error.new("Unknown portal token audience: #{aud}")
    end
    now = Time.now.to_i
    payload = aud ? {} : { alg: self.hmac_algorithm }
    payload.merge!(
      iss: APP_CONFIG[:site_url],
      iat: now,
      exp: now + expires_in,
      uid: user.id
    )
    payload[:aud] = aud if aud
    claims = claims.dup
    claims[:minted_via_oidc_client_id] ||= Current.minted_via_oidc_client_id if Current.minted_via_oidc_client_id
    claims[:minted_for]                ||= Current.minted_for                if Current.minted_for
    # merge claims into payload, preventing duplicates
    payload.merge!(claims) { |key, old, new| fail "Duplicate JWT claim key: #{key}" }
    begin
      if aud
        JWT.encode payload, PortalSigningKey.private_key, PortalSigningKey::ALGORITHM, { kid: PortalSigningKey.kid }
      else
        JWT.encode payload, self.hmac_secret, self.hmac_algorithm
      end
    rescue SignedJwt::Error
      raise
    rescue StandardError => e
      raise SignedJwt::Error.new(e.message)
    end
  end

  # aud is the RS256 audience this call site accepts, or nil to accept no RS256 token at
  # all. Tokens are routed by the kid header: with one, RS256 is pinned and the key is the
  # one that kid names; without one, HS256 is pinned against JWT_HMAC_SECRET, which is
  # every legacy portal token. The token's own alg never chooses the key.
  def self.decode_portal_token(token, aud:)
    begin
      header = JWT.decode(token, nil, false)[1]
      decoded =
        if header.key?('kid')
          raise SignedJwt::Error.new('This endpoint does not accept RS256 portal tokens') if aud.nil?
          JWT.decode(token, nil, true, { algorithm: PortalSigningKey::ALGORITHM, aud: aud, verify_aud: true }) do |h|
            PortalSigningKey.verification_key(h['kid'])
          end.tap do |d|
            # The gem accepts an aud array containing the expected value; rigse never mints one.
            raise SignedJwt::Error.new('Portal token aud must be a single string') unless d[0]['aud'].is_a?(String)
          end
        else
          JWT.decode token, self.hmac_secret, true, {algorithm: self.hmac_algorithm}
        end
    rescue JWT::ExpiredSignature, SignedJwt::Error
      raise
    rescue StandardError => e
      raise SignedJwt::Error.new(e.message)
    end
    {data: decoded[0], header: decoded[1]}
  end

  def self.create_firebase_token(uid, firebase_app_name, expires_in=3600, claims={})
    app = FirebaseApp.find_by_name(firebase_app_name)
    raise SignedJwt::Error.new("Unknown firebase app name: #{firebase_app_name}") if app.nil?

    now = Time.now.to_i
    iat = now - CLOCK_SKEW_ALLOWANCE
    payload = {
      alg: self.rsa_algorithm,
      iss: app.client_email,
      sub: app.client_email,
      aud: 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit',
      iat: iat,
      exp: iat + expires_in,
      uid: uid
    }

    begin
      # merge claims into payload, preventing duplicates
      payload.merge!(claims) { |key, old, new| fail "Duplicate JWT claim key: #{key}" }
      rsa_private = OpenSSL::PKey::RSA.new(app.private_key)
      JWT.encode payload, rsa_private, self.rsa_algorithm
    rescue StandardError => e
      raise SignedJwt::Error.new(e.message)
    end
  end

  # for tests to check token
  def self.decode_firebase_token(token, firebase_app_name)
    app = FirebaseApp.find_by_name(firebase_app_name)
    raise SignedJwt::Error.new("Unknown firebase app name: #{firebase_app_name}") if app.nil?

    begin
      rsa_private = OpenSSL::PKey::RSA.new(app.private_key)
      decoded = JWT.decode token, rsa_private, true, {algorithm: self.rsa_algorithm}
    rescue StandardError => e
      raise SignedJwt::Error.new(e.message)
    end
    {data: decoded[0], header: decoded[1]}
  end

  # Verify a forwarded Firebase custom token, selecting the RSA key from the
  # token's iss (= FirebaseApp#client_email) rather than a caller-supplied app
  # name. Signature and exp are enforced with zero clock skew. Returns
  # {data:, header:, app:}. Raises SignedJwt::Error on any failure.
  def self.decode_firebase_token_by_iss(token)
    unverified = begin
      JWT.decode(token, nil, false).first
    rescue StandardError => e
      raise SignedJwt::Error.new("Undecodable forwarded token: #{e.message}")
    end
    iss = unverified && unverified['iss']
    raise SignedJwt::Error.new('Forwarded token has no iss') if iss.blank?

    apps = FirebaseApp.where(client_email: iss).to_a
    raise SignedJwt::Error.new("No FirebaseApp for iss=#{iss}") if apps.empty?

    app, decoded = verify_against_any(token, apps)
    raise SignedJwt::Error.new("Signature did not verify for iss=#{iss}") unless app
    {data: decoded[0], header: decoded[1], app: app}
  end

  def self.verify_against_any(token, apps)
    apps.each do |app|
      begin
        rsa = OpenSSL::PKey::RSA.new(app.private_key)
        decoded = JWT.decode(token, rsa, true, {algorithm: self.rsa_algorithm})
        return [app, decoded]
      rescue JWT::ExpiredSignature
        raise SignedJwt::Error.new('Forwarded token expired')
      rescue StandardError
        next
      end
    end
    [nil, nil]
  end

  def self.is_valid_private_key?(private_key)
    begin
      rsa_private = OpenSSL::PKey::RSA.new(private_key)
      JWT.encode({}, rsa_private, self.rsa_algorithm)
    rescue StandardError => e
      return false
    end
    return true
  end

  # JWTs always contain dots (header.payload.signature); AccessGrant tokens
  # are SecureRandom.hex(16) and never contain dots. This lets callers route
  # Bearer tokens to the right handler without decoding.
  def self.probably_jwt?(token)
    token.include?('.')
  end

  # Peeks at the unverified JWT payload to determine if this is a
  # Portal-issued token. Returns true if the iss matches the site URL,
  # or for legacy tokens that have uid but no iss claim.
  def self.portal_token?(token)
    return false unless probably_jwt?(token)
    unverified = begin
      JWT.decode(token, nil, false).first
    rescue JWT::DecodeError
      nil
    end
    return false unless unverified
    unverified['iss'] == APP_CONFIG[:site_url] || (unverified.key?('uid') && !unverified.key?('iss'))
  end

  private

  def self.hmac_algorithm
    'HS256'
  end

  def self.rsa_algorithm
    'RS256'
  end

  def self.hmac_secret
    secret = ENV['JWT_HMAC_SECRET']
    raise SignedJwt::Error.new('No HMAC signing secret (JWT_HMAC_SECRET) found in environment') if secret.blank?
    secret
  end
end
