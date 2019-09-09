class AccessGrant < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
  belongs_to :learner, :class_name => "Portal::Learner"
  belongs_to :teacher, :class_name => "Portal::Teacher"
  before_create :generate_tokens

  attr_accessible :access_token, :access_token_expires_at, :client_id, :code, :refresh_token, :state, :user_id, :learner_id, :teacher_id
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

  # Pretty much perform the 1st step of the OAuth2 authorization.
  def self.get_authorize_redirect_uri(user, params)
    client = Client.find_by_app_id(params[:client_id])
    unless client
      raise "Client not found"
    end
    unless SUPPORTED_RESPONSE_TYPES.include?(params[:response_type])
      # https://tools.ietf.org/html/rfc6749#section-4.2.2.1
      return client.get_redirect_uri(params[:redirect_uri], error: "unsupported_response_type")
    end

    AccessGrant.prune!
    access_grant = user.access_grants.create({:client => client, :state => params[:state]}, :without_protection => true)

    if client.client_type == Client::PUBLIC && params[:response_type] === "token"
      # Implicit flow for public clients (e.g. Glossary Authoring).
      access_grant.start_expiry_period!
      access_grant.implicit_flow_redirect_uri_for(params[:redirect_uri])
    elsif client.client_type == Client::CONFIDENTIAL && params[:response_type] === "code"
      # Auth code flow (two steps) for confidential clients (e.g. LARA).
      access_grant.auth_code_redirect_uri_for(params[:redirect_uri])
    else
      # https://tools.ietf.org/html/rfc6749#section-4.2.2.1
      client.get_redirect_uri(params[:redirect_uri], error: "unauthorized_client")
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
