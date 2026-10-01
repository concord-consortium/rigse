# The portal JWT in a request's Authorization header, if any. The global capability check,
# the Devise JWT strategy and check_for_auth_token all read the header through raw_token, so
# a header form that one of them accepts can never slip past another.
module PortalBearer
  # The credential after "Bearer" or "Bearer/JWT" and any whitespace, or nil.
  def self.raw_token(header)
    return nil unless header
    $1 if header =~ /^Bearer(?:\/JWT)?\s+(.+)$/i
  end

  # Bearer/JWT is the legacy portal scheme, kept for the HS256 portal JWTs clients already send.
  def self.legacy_scheme?(header)
    header.to_s.match?(/^Bearer\/JWT/i)
  end

  # An RS256 access token is accepted only as plain Bearer (RFC 6750). `jwt_header` is the
  # verified token's header.
  def self.scheme_accepts?(header, jwt_header)
    !(legacy_scheme?(header) && SignedJwt.access_token_header?(jwt_header))
  end

  # The request's credential if it is a portal JWT. An opaque AccessGrant token never
  # contains a dot and is not one.
  def self.token(request)
    token = raw_token(request.headers['Authorization'])
    token if token && SignedJwt.portal_token?(token)
  end

  # The verified payload of the request's portal JWT, or nil when there is none or it does
  # not verify. A bearer that does not verify authenticates no one anywhere, so the callers
  # of this treat it as absent.
  def self.verified_claims(request)
    token = token(request)
    return nil unless token
    SignedJwt.decode_portal_token(token)[:data]
  rescue SignedJwt::Error, JWT::ExpiredSignature
    nil
  end
end
