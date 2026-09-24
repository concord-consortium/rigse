# The environment's RS256 keypair, which signs every portal token that is not a legacy
# HS256 one. The private key lives only in rigse's configuration; report-server and the
# report-service function hold the public half as a configured value keyed by kid.
#
# PORTAL_SIGNING_KEY          PEM private key; literal "\n" sequences are accepted so it
#                             fits in one environment value
# PORTAL_SIGNING_KEY_ID       its kid
# PORTAL_PREVIOUS_VERIFY_KEYS optional JSON object of kid => public PEM, for tokens signed
#                             by the previous key during a rotation
#
# Staging and production must not share a keypair, or a staging token verifies in production.
module PortalSigningKey
  ALGORITHM = 'RS256'.freeze

  def self.configured?
    ENV['PORTAL_SIGNING_KEY'].present? && ENV['PORTAL_SIGNING_KEY_ID'].present?
  end

  def self.kid
    ENV['PORTAL_SIGNING_KEY_ID'].presence ||
      raise(SignedJwt::Error, 'No portal signing key id (PORTAL_SIGNING_KEY_ID) found in environment')
  end

  def self.private_key
    pem = ENV['PORTAL_SIGNING_KEY'].presence ||
      raise(SignedJwt::Error, 'No portal signing key (PORTAL_SIGNING_KEY) found in environment')
    parse(pem, 'PORTAL_SIGNING_KEY')
  end

  # Always an OpenSSL::PKey, never a PEM string: the jwt gem verifies an HS256 token
  # signed with the public PEM as its secret when handed the PEM string and an algorithm
  # list that includes HS256.
  def self.verification_key(kid)
    verification_keys.fetch(kid) do
      raise SignedJwt::Error, "Unrecognized portal signing key id: #{kid.inspect}"
    end
  end

  def self.verification_keys
    keys = {}
    keys[kid] = private_key.public_key if configured?
    previous = ENV['PORTAL_PREVIOUS_VERIFY_KEYS'].presence
    if previous
      JSON.parse(previous).each do |previous_kid, pem|
        keys[previous_kid] ||= parse(pem, "PORTAL_PREVIOUS_VERIFY_KEYS[#{previous_kid}]")
      end
    end
    keys
  rescue JSON::ParserError => e
    raise SignedJwt::Error, "PORTAL_PREVIOUS_VERIFY_KEYS is not valid JSON: #{e.message}"
  end

  def self.parse(pem, name)
    @parsed ||= {}
    @parsed[pem] ||= OpenSSL::PKey::RSA.new(pem.gsub('\n', "\n"))
  rescue OpenSSL::PKey::RSAError => e
    raise SignedJwt::Error, "#{name} is not a valid RSA key: #{e.message}"
  end
  private_class_method :parse
end
