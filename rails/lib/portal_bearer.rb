# The portal JWT in a request's Authorization header, if any. The global capability check,
# the Devise JWT strategy and check_for_auth_token all read the header through raw_token, so
# a header form that one of them accepts can never slip past another.
module PortalBearer
  # The credential after "Bearer" or "Bearer/JWT" and any whitespace, or nil.
  def self.raw_token(header)
    return nil unless header
    $1 if header =~ /^Bearer(?:\/JWT)?\s+(.+)$/i
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
