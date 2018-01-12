module SignedJWT

  require 'jwt'

  class Error < StandardError
  end

  def self.create_portal_token(user, claims={}, expires_in=3600)
    now = Time.now.to_i
    payload = {
      alg: self.hmac_algorithm,
      iat: now,
      exp: now + expires_in,
      uid: user.id
    }
    # merge claims into payload, preventing duplicates
    payload.merge!(claims) { |key, old, new| fail "Duplicate JWT claim key: #{key}" }
    begin
      JWT.encode payload, self.hmac_secret, self.hmac_algorithm
    rescue Exception => e
      raise SignedJWT::Error.new(e.message)
    end
  end

  def self.decode_portal_token(token)
    begin
      decoded = JWT.decode token, self.hmac_secret, true, {algorithm: self.hmac_algorithm}
    rescue Exception => e
      raise SignedJWT::Error.new(e.message)
    end
    {data: decoded[0], header: decoded[1]}
  end

  def self.create_firebase_token(user, firebase_app_name, expires_in=3600, claims={})
    app = FirebaseApp.find_by_name(firebase_app_name)
    raise SignedJWT::Error.new("Unknown firebase app name: #{firebase_app_name}") if app.nil?

    now = Time.now.to_i
    payload = {
      alg: self.rsa_algorithm,
      iss: app.client_email,
      sub: app.client_email,
      aud: 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit',
      iat: now,
      exp: now + expires_in,
      uid: user.id
    }

    begin
      # merge claims into payload, preventing duplicates
      payload.merge!(claims) { |key, old, new| fail "Duplicate JWT claim key: #{key}" }
      rsa_private = OpenSSL::PKey::RSA.new(app.private_key)
      JWT.encode payload, rsa_private, self.rsa_algorithm
    rescue Exception => e
      raise SignedJWT::Error.new(e.message)
    end
  end

  # for tests to check token
  def self.decode_firebase_token(token, firebase_app_name)
    app = FirebaseApp.find_by_name(firebase_app_name)
    raise SignedJWT::Error.new("Unknown firebase app name: #{firebase_app_name}") if app.nil?

    begin
      rsa_private = OpenSSL::PKey::RSA.new(app.private_key)
      decoded = JWT.decode token, rsa_private, true, {algorithm: self.rsa_algorithm}
    rescue Exception => e
      raise SignedJWT::Error.new(e.message)
    end
    {data: decoded[0], header: decoded[1]}
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
    raise SignedJWT::Error.new('No HMAC signing secret (JWT_HMAC_SECRET) found in environment') if secret.blank?
    secret
  end
end
