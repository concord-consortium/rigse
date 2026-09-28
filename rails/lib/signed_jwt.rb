module SignedJwt

  require 'jwt'

  # Seconds to backdate the issued-at (iat) claim in Firebase JWTs,
  # compensating for clock skew between this server and Google.
  CLOCK_SKEW_ALLOWANCE = 30

  class Error < StandardError
  end

  # The audiences of the two service assertions rigse signs. rigse accepts neither as a
  # bearer: the only RS256 token it accepts is its own scoped access token.
  AUD_REPORT_SERVER            = 'report-server'.freeze
  AUD_REPORT_SERVICE_FUNCTIONS = 'report-service-functions'.freeze
  ASSERTION_AUDIENCES = [AUD_REPORT_SERVER, AUD_REPORT_SERVICE_FUNCTIONS].freeze

  # RFC 9068's media type for a JWT access token, set as the header typ. A verifier that
  # requires it can never mistake an assertion, which has none, for an access token.
  ACCESS_TOKEN_TYPE = 'at+jwt'.freeze

  # The legacy HS256 portal token. A token minted during a request authenticated by a
  # scoped token inherits its scope and context, as it inherits the service-mint marker.
  def self.create_portal_token(user, claims={}, expires_in=3600)
    now = Time.now.to_i
    payload = {
      alg: self.hmac_algorithm,
      iss: APP_CONFIG[:site_url],
      iat: now,
      exp: now + expires_in,
      uid: user.id
    }
    claims = claims.dup
    claims[:minted_via_oidc_client_id] ||= Current.minted_via_oidc_client_id if Current.minted_via_oidc_client_id
    claims[:minted_for]                ||= Current.minted_for                if Current.minted_for
    TokenScope.inherited_claims.each { |key, value| claims[key] ||= value unless claims.key?(key.to_s) }
    # merge claims into payload, preventing duplicates
    payload.merge!(claims) { |key, old, new| fail "Duplicate JWT claim key: #{key}" }
    begin
      JWT.encode payload, self.hmac_secret, self.hmac_algorithm
    rescue StandardError => e
      raise SignedJwt::Error.new(e.message)
    end
  end

  # A short-lived RS256 assertion for another service, with exactly one audience.
  def self.create_assertion(user, aud:, claims: {}, expires_in:)
    raise SignedJwt::Error.new("Unknown assertion audience: #{aud}") unless ASSERTION_AUDIENCES.include?(aud)
    now = Time.now.to_i
    payload = { iss: APP_CONFIG[:site_url], aud: aud, iat: now, exp: now + expires_in, uid: user.id }
    payload.merge!(claims) { |key, old, new| fail "Duplicate JWT claim key: #{key}" }
    sign_rs256(payload)
  end

  # The scoped access token /oauth/token issues (RFC 9068). `aud` lists every service whose
  # capability the token carries, rigse always first, and never an assertion's audience: a
  # verifier that accepts any list containing its audience must not take this as one.
  def self.create_access_token(user, client_id:, capabilities:, context:, audiences:, expires_in:)
    audiences = Array(audiences)
    unless audiences.first == APP_CONFIG[:site_url] && (audiences & ASSERTION_AUDIENCES).empty?
      raise SignedJwt::Error.new("An access token's aud must start with this portal and name no assertion audience: #{audiences.inspect}")
    end
    now = Time.now.to_i
    payload = {
      iss: APP_CONFIG[:site_url],
      sub: user.id.to_s,
      uid: user.id,
      aud: audiences,
      client_id: client_id,
      scope: capabilities.join(' '),
      iat: now,
      exp: now + expires_in,
      jti: SecureRandom.uuid
    }
    payload[:context] = context if context
    sign_rs256(payload, typ: ACCESS_TOKEN_TYPE)
  end

  def self.sign_rs256(payload, header = {})
    JWT.encode payload, PortalSigningKey.private_key, PortalSigningKey::ALGORITHM, header.merge(kid: PortalSigningKey.kid)
  rescue SignedJwt::Error
    raise
  rescue StandardError => e
    raise SignedJwt::Error.new(e.message)
  end
  private_class_method :sign_rs256

  # Routes by the kid header, never by the token's own alg: RS256 only for rigse's own
  # at+jwt access token, HS256 for every legacy portal token. Assertions are refused.
  def self.decode_portal_token(token)
    begin
      header = JWT.decode(token, nil, false)[1]
      decoded =
        if header.key?('kid')
          raise SignedJwt::Error.new('An RS256 portal token must be an access token') unless header['typ'] == ACCESS_TOKEN_TYPE
          JWT.decode(token, nil, true, { algorithm: PortalSigningKey::ALGORITHM, aud: APP_CONFIG[:site_url], verify_aud: true }) do |h|
            PortalSigningKey.verification_key(h['kid'])
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
