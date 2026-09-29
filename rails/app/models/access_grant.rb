class AccessGrant < ApplicationRecord
  belongs_to :user
  belongs_to :client
  belongs_to :learner, :class_name => "Portal::Learner"
  belongs_to :teacher, :class_name => "Portal::Teacher"
  before_create :refuse_service_minted_tokens
  before_create :refuse_opaque_grants_for_scoped_clients
  before_create :generate_tokens

  ExpireTime = 1.week

  # How long an authorization code may wait to be redeemed. Every client redeems at once,
  # so this only has to cover a slow redirect; single use is what stops a replay.
  CodeExpireTime = 5.minutes

  # RFC 7636: only S256 is accepted; "plain" would put the verifier itself in the URL.
  CODE_CHALLENGE_METHOD = "S256"

  # RFC 7636 4.1 and 4.2: a verifier, and so a challenge, is 43 to 128 unreserved characters.
  PKCE_VALUE = /\A[A-Za-z0-9\-._~]{43,128}\z/

  # Set on a grant created by response_type=code, the only kind with a redeemable code.
  attr_accessor :issue_code

  # Returns all access grants valid at given time, ordered by expire date.
  scope :valid_at, lambda { |time| where("access_token_expires_at > ?", time).order('access_token_expires_at DESC') }

  SUPPORTED_RESPONSE_TYPES = ["token", "code"]

  def self.prune!
    AccessGrant.where(["access_token_expires_at < ?", 1.minute.ago]).delete_all
    AccessGrant.where(access_token_expires_at: nil).where.not(code: nil)
      .where(["created_at < ?", CodeExpireTime.ago]).delete_all
  end

  # The grant a code redeems, if the code is live: issued to this client, by the code flow,
  # not yet redeemed and not expired.
  def self.authenticate(code, client_id)
    return nil if code.blank?
    AccessGrant.where(code: code, client_id: client_id).where(["created_at > ?", CodeExpireTime.ago]).first
  end

  ValidationResult = Struct.new(:valid, :client, :error_redirect, :scope, :context) do
    def valid?
      valid
    end

    # RFC 6749 4.1.2.1: an error response carries the request's state, or a client that
    # checks state cannot tell a genuine error from a forged one.
    def error(error_msg, redirect_uri, state = nil)
      query = { error: error_msg }
      query[:state] = state if state.present?
      self.error_redirect = client.get_redirect_uri(redirect_uri, query)
      self.valid = false
    end
  end

  def self.matching_response_type(client, response_type, params)
    if client.scoped?
      # A scoped token never travels in a URL, so a scoped client uses the code flow only.
      response_type === "code" && (!client.public? || params[:code_challenge].present?)
    elsif client.client_type == Client::PUBLIC
      # Implicit flow for public clients (e.g. Glossary Authoring), or the code flow with PKCE.
      response_type === "token" || (response_type === "code" && params[:code_challenge].present?)
    else
      # Auth code flow (two steps) for confidential clients (e.g. LARA).
      client.client_type == Client::CONFIDENTIAL && response_type === "code"
    end
  end

  # There are two types of validation errors "hard" and "soft".
  #
  # "hard" errors happen when the client is not found or redirect_uri is malformed or
  #   not registered.
  #
  # "soft" errors happen when the redirect_uri is fine. In these cases the user should be
  #   redirected back to the client with an error url parameter containing the error
  #   message.
  #
  # For a "hard" error validate_oauth_authorize raises an RuntimeError.
  #   Without additional handling the user will see a 500 error.
  #
  # For a "soft" error validate_oauth_authorize returns an object with a obj.valid false,
  #   and obj.error_redirect a string with the url to redirect to. The caller is
  #   responsible for checking this return value and redirecting if necessary.
  def self.validate_oauth_authorize(params)
    result = ValidationResult.new(false, nil, nil)
    # use first! with the bang to raise an exception if it doesn't exist
    result.client = Client.where(app_id: params[:client_id]).first!

    # this will raise an error if the redirect_uri is invalid
    result.client.check_redirect_uri(params[:redirect_uri])
    redirect_uri, state = params[:redirect_uri], params[:state]

    if ! SUPPORTED_RESPONSE_TYPES.include?(params[:response_type])
      # https://tools.ietf.org/html/rfc6749#section-4.2.2.1
      result.error("unsupported_response_type", redirect_uri, state)
    elsif (params[:code_challenge].present? || params[:code_challenge_method].present?) &&
          (params[:code_challenge_method] != CODE_CHALLENGE_METHOD ||
           !params[:code_challenge].is_a?(String) || params[:code_challenge] !~ PKCE_VALUE)
      result.error("invalid_request", redirect_uri, state)
    elsif ! self.matching_response_type(result.client, params[:response_type], params)
      # https://tools.ietf.org/html/rfc6749#section-4.2.2.1
      error = result.client.public? && params[:response_type] === "code" ? "invalid_request" : "unauthorized_client"
      result.error(error, redirect_uri, state)
    elsif result.client.scoped?
      validate_scope_and_context(result, params)
    else
      result.valid = true
    end

    result
  end

  # A scoped client's request: the scope must be within the client's, and a context-bound
  # capability needs a context of its type.
  def self.validate_scope_and_context(result, params)
    redirect_uri, state = params[:redirect_uri], params[:state]
    allowed = result.client.scope_list
    requested = params[:scope].present? ? TokenCapabilities.parse(params[:scope]) : allowed
    return result.error("invalid_scope", redirect_uri, state) if requested.empty? || (requested - allowed).any?

    context_types = TokenCapabilities.context_types(requested)
    context = parse_context(params[:context])
    if params[:context].present? && context.nil?
      return result.error("invalid_request", redirect_uri, state)
    end
    if context_types.any? && context.nil?
      return result.error("invalid_request", redirect_uri, state)
    end
    if context && !context_types.include?(context[:type])
      return result.error("invalid_request", redirect_uri, state)
    end

    result.scope = requested
    result.context = context
    result.valid = true
  end

  # "class:123" => {type: "class", id: 123}
  def self.parse_context(value)
    return nil unless value.is_a?(String) && value =~ /\A([a-z][a-z0-9-]*):([1-9][0-9]*)\z/
    { type: $1, id: $2.to_i }
  end

  # Pretty much perform the 1st step of the OAuth2 authorization.
  def self.get_authorize_redirect_uri(user, params)
    # this validation might have already happened before, if the user wasn't logged in
    # but if the user was already logged in then this will be first time the validation
    # is done
    validation = self.validate_oauth_authorize(params)

    if !validation.valid
      return validation.error_redirect
    end

    client = validation.client
    if client.scoped?
      error = authorize_scope_for(user, validation.scope, validation.context)
      if error
        validation.error(error, params[:redirect_uri], params[:state])
        return validation.error_redirect
      end
    end

    AccessGrant.prune!
    attributes = { :client => client, :state => params[:state] }
    if params[:response_type] === "code"
      attributes.merge!(
        :issue_code => true,
        :code_challenge => params[:code_challenge].presence,
        :redirect_uri => params[:redirect_uri],
        :scope => validation.scope&.join(' '),
        :context_type => validation.context&.dig(:type),
        :context_id => validation.context&.dig(:id)
      )
    end
    access_grant = user.access_grants.create(attributes)

    # validate_oauth_authorize already checked that this client settings matched the response_type
    if params[:response_type] === "token"
      # Implicit flow for public clients (e.g. Glossary Authoring).
      access_grant.start_expiry_period!
      access_grant.implicit_flow_redirect_uri_for(params[:redirect_uri])
    elsif params[:response_type] === "code"
      # Auth code flow (two steps) for confidential clients (e.g. LARA), and for public ones with PKCE.
      access_grant.auth_code_redirect_uri_for(params[:redirect_uri])
    else
      # we shouldn't be here because validate_oauth_authorize should have handled this case
      raise "error validating request"
    end
  end

  # The error to redirect with, or nil when the user may have a token with this scope bound
  # to this context. A missing object and a refused one are the same access_denied, so the
  # endpoint cannot be used to find out which classes exist.
  def self.authorize_scope_for(user, scope, context)
    # No code is issued that /oauth/token could not honour.
    unless PortalSigningKey.usable?
      Rails.logger.error("OAuth authorize: a scoped client needs a valid PORTAL_SIGNING_KEY and PORTAL_SIGNING_KEY_ID, which are not configured")
      return "server_error"
    end
    missing = TokenCapabilities.missing_settings(scope)
    if missing.any?
      Rails.logger.error("OAuth authorize: #{scope.join(' ')} needs #{missing.join(', ')}, which is not configured")
      return "server_error"
    end
    return nil unless context
    object = TokenCapabilities.context_record(context[:type], context[:id])
    return "access_denied" unless object
    gates = scope.map { |name| TokenCapabilities.fetch(name) }.select { |c| c.context_type == context[:type] }.map(&:gate).compact
    gates.all? { |gate| gate.call(user, object) } ? nil : "access_denied"
  end

  def scope_list
    TokenCapabilities.parse(scope)
  end

  def context
    context_type.present? ? { type: context_type, id: context_id } : nil
  end

  # RFC 7636 4.6: BASE64URL(SHA256(verifier)) must equal the stored challenge.
  def verifies_code_verifier?(verifier)
    return true if code_challenge.blank?
    return false unless verifier.is_a?(String) && verifier =~ PKCE_VALUE
    computed = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
    ActiveSupport::SecurityUtils.secure_compare(computed, code_challenge)
  end

  # Spends the code, so it can be redeemed only once even by two requests racing. Returns
  # false if another request spent it first.
  def spend_code!
    AccessGrant.where(id: id).where.not(code: nil).update_all(code: nil) == 1
  end

  # A scoped client's grant only carries its code across the redirect, so it gets no opaque
  # token at all: the scoped JWT is the only credential such a client ever receives.
  def generate_tokens
    self.code = issue_code ? SecureRandom.hex(16) : nil
    if client&.scoped?
      self.access_token = self.refresh_token = nil
    else
      self.access_token, self.refresh_token = SecureRandom.hex(16), SecureRandom.hex(16)
    end
  end

  # The only grant a scoped client may have is a code-flow grant; anything else would be an
  # unscoped opaque credential for it.
  def refuse_opaque_grants_for_scoped_clients
    return unless client&.scoped? && !issue_code
    errors.add(:base, 'a scoped client gets its token from the code flow, never an opaque grant')
    throw :abort
  end

  # A scoped or service-minted token must never be turned into an unscoped opaque one.
  def refuse_service_minted_tokens
    return if Current.minted_via_oidc_client_id.blank? && !TokenScope.scoped?
    errors.add(:base, 'cannot be created from a scoped or service-minted token')
    throw :abort
  end

  # Auth code flow 1st step is to redirect back to client with code.
  def auth_code_redirect_uri_for(redirect_uri)
    client.get_redirect_uri(redirect_uri, {
      code: code,
      response_type: "code",
      state: state
    })
  end

  # Implicit token flow immediately returns access token. See: https://tools.ietf.org/html/rfc6749#section-4.2.2
  def implicit_flow_redirect_uri_for(redirect_uri)
    client.get_redirect_uri(redirect_uri, nil, {
      access_token: access_token,
      token_type: "bearer",
      expires_in: ExpireTime.to_s, # seconds
      state: state
      # scope is an optional param that we might support one day
    })
  end

  def start_expiry_period!
    self.update_attribute(:access_token_expires_at, Time.now + ExpireTime)
  end
end
