class AccessGrant < ApplicationRecord
  belongs_to :user
  belongs_to :client
  belongs_to :learner, :class_name => "Portal::Learner"
  belongs_to :teacher, :class_name => "Portal::Teacher"
  before_create :generate_tokens

  ExpireTime = 1.week

  # Returns all access grants valid at given time, ordered by expire date.
  scope :valid_at, lambda { |time| where("access_token_expires_at > ?", time).order('access_token_expires_at DESC') }

  SUPPORTED_RESPONSE_TYPES = ["token", "code"]

  def self.prune!
    # We need to delete tokens that have expired...
    delete_all(["access_token_expires_at < ?", 1.minute.ago])
  end

  def self.authenticate(code, client_id)
    AccessGrant.where("code = ? AND client_id = ?", code, client_id).first
  end

  ValidationResult = Struct.new(:valid, :client, :error_redirect) do
    def valid?
      valid
    end

    def error(error_msg, redirect_uri)
      self.error_redirect = client.get_redirect_uri(redirect_uri, error: error_msg)
      self.valid = false
    end
  end

  def self.matching_response_type(client_type, response_type)
    # Implicit flow for public clients (e.g. Glossary Authoring).
    (client_type == Client::PUBLIC && response_type === "token") ||
    # Auth code flow (two steps) for confidential clients (e.g. LARA).
    (client_type == Client::CONFIDENTIAL && response_type === "code")
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

    if ! SUPPORTED_RESPONSE_TYPES.include?(params[:response_type])
      # https://tools.ietf.org/html/rfc6749#section-4.2.2.1
      result.error("unsupported_response_type", params[:redirect_uri])
    elsif ! self.matching_response_type(result.client.client_type, params[:response_type])
      # https://tools.ietf.org/html/rfc6749#section-4.2.2.1
      result.error("unauthorized_client", params[:redirect_uri])
    else
      result.valid = true
    end

    result
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

    AccessGrant.prune!
    access_grant = user.access_grants.create({:client => client, :state => params[:state]})

    # validate_oauth_authorize already checked that this client settings matched the response_type
    if params[:response_type] === "token"
      # Implicit flow for public clients (e.g. Glossary Authoring).
      access_grant.start_expiry_period!
      access_grant.implicit_flow_redirect_uri_for(params[:redirect_uri])
    elsif params[:response_type] === "code"
      # Auth code flow (two steps) for confidential clients (e.g. LARA).
      access_grant.auth_code_redirect_uri_for(params[:redirect_uri])
    else
      # we shouldn't be here because validate_oauth_authorize should have handled this case
      raise "error validating request"
    end
  end

  def generate_tokens
    self.code, self.access_token, self.refresh_token = SecureRandom.hex(16), SecureRandom.hex(16), SecureRandom.hex(16)
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
