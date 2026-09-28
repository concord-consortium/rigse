class AuthController < ApplicationController

  before_action :verify_logged_in, :except => [ :access_token,
                                                :login,
                                                :oauth_authorize,
                                                :reauth ]

  skip_before_action :authenticate_user!, :only => [:authorize], :raise => false  # this is handled by verify_logged_in
  skip_before_action :verify_authenticity_token, :only => [:access_token]

  def verify_logged_in
    if current_user.nil?
        redirect_to auth_login_path
    end
  end


  def login
    # Renders a nice login form (views/auth/login.haml).
    @app_name = params[:app_name]
    @error = flash['alert']
    @after_sign_in_path = params[:after_sign_in_path]
    # If the user is already signed in and there is is a after_sign_in_path set
    # then redirect the user to this page.
    if @after_sign_in_path and current_user
      # add an extra param before redirecting to so we don't show the user an extra
      # warning message see pundit_user_not_authorized
      redirect_uri = URI.parse(@after_sign_in_path)
      query = Rack::Utils.parse_query(redirect_uri.query)
      query["redirecting_after_sign_in"] = '1'
      redirect_uri.query = Rack::Utils.build_query(query)
      redirect_to @after_sign_in_path
    elsif current_user
      #
      # User is signed in but there is no after_sign_in_path
      #
      redirect_to view_context.current_user_home_path
    else
      render :layout => false
    end
  end

  def reauth
    sign_out(current_user) if current_user
    after_sign_in_path = params[:after_sign_in_path]
    redirect_to auth_login_path(after_sign_in_path: after_sign_in_path)
  end

  def oauth_authorize
    if current_user.nil?
      validation = AccessGrant.validate_oauth_authorize(params)
      if (!validation.valid)
        redirect_to validation.error_redirect, allow_other_host: true
        return
      end

      # if the parameters are valid then the validation will have a client
      # we send the clients name to the login box so it can display a helpful name
      app_name = validation.client.name
      redirect_to auth_login_path(after_sign_in_path: request.fullpath, app_name: app_name)
      return
    end

    # Check login_hint: if present and doesn't match current user, show warning
    if params[:login_hint].present? && current_user.id.to_s != params[:login_hint]
      @user_name = current_user.name
      @app_name = Client.where(app_id: params[:client_id]).first&.name

      # Build continue URL: same params minus login_hint
      continue_params = request.query_parameters.except("login_hint")
      @continue_url = "#{request.path}?#{continue_params.to_query}"

      # Build switch user URL: reauth signs out then redirects to login with after_sign_in_path
      @switch_user_url = auth_reauth_path(after_sign_in_path: @continue_url)

      render 'auth/login_hint_mismatch', layout: false
      return
    end

    # Note that we'll get to this point only if user is currently logged in.
    # If user is not logged in, we'll redirect back here after first
    # logging in the user. This redirect happens when in
    # ApplicationController#after_sign_in_path_for
    redirect_to AccessGrant.get_authorize_redirect_uri(current_user, params), allow_other_host: true
  end

  def access_token
    client = Client.find_by(app_id: params[:client_id])
    if client && (client.public? || client.scoped?)
      return pkce_or_scoped_access_token(client)
    end

    application = Client.authenticate(params[:client_id], params[:client_secret])

    if application.nil?
      render :json => {:error => "Could not find application"}
      return
    end

    access_grant = AccessGrant.authenticate(params[:code], application.id)
    if access_grant.nil? || !access_grant.verifies_code_verifier?(params[:code_verifier]) ||
       !legacy_redirect_uri_matches?(access_grant, application) || !access_grant.spend_code!
      render :json => {:error => "Could not authenticate access code"}
      return
    end

    access_grant.start_expiry_period!
    render :json => {:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => Devise.timeout_in.to_i}
  end

  private

  # Token endpoint for public (PKCE) and scoped clients; errors follow RFC 6749 5.2.
  # A public client holds no secret and proves itself with its PKCE verifier.
  def pkce_or_scoped_access_token(client)
    if params[:grant_type].present? && params[:grant_type] != "authorization_code"
      return oauth_error("unsupported_grant_type", 400)
    end
    unless client.public? || Client.authenticate(params[:client_id], params[:client_secret])
      return oauth_error("invalid_client", 401)
    end

    grant = AccessGrant.authenticate(params[:code], client.id)
    return oauth_error("invalid_grant", 400) unless grant
    return oauth_error("invalid_grant", 400) if client.public? && grant.code_challenge.blank?
    return oauth_error("invalid_grant", 400) unless grant.verifies_code_verifier?(params[:code_verifier])
    return oauth_error("invalid_grant", 400) if grant.redirect_uri.present? && params[:redirect_uri] != grant.redirect_uri

    client.scoped? ? issue_scoped_access_token(client, grant) : issue_opaque_access_token(grant)
  end

  # RFC 6749 4.1.3: a mismatched redirect_uri is refused, and so is a missing one for a PKCE
  # code; otherwise a missing one is logged and accepted, since not every confidential
  # client sends it (Model My Watershed omits it).
  def legacy_redirect_uri_matches?(grant, client)
    return true if grant.redirect_uri.blank?
    if params[:redirect_uri].blank?
      return false if grant.code_challenge.present?
      Rails.logger.warn("OAuth token: #{client.name} (#{client.app_id}) redeemed a code without redirect_uri")
      return true
    end
    params[:redirect_uri] == grant.redirect_uri
  end

  # The grant row exists only to carry the code across the redirect. The token is signed
  # before the code is spent, so a signing failure leaves the code for a retry; the grant
  # is then deleted only if this request still holds its code, so a concurrent redemption
  # cannot also succeed, and a token signed for a lost race is discarded unsent.
  def issue_scoped_access_token(client, grant)
    # Only what the client may still request, in case its scopes narrowed since the code.
    capabilities = grant.scope_list & client.scope_list
    return oauth_error("invalid_grant", 400) if capabilities.empty?
    audiences = capabilities.map { |c| TokenCapabilities.audience_value(c) }
    return oauth_error("server_error", 500) if audiences.any?(&:nil?)
    ttl = ExternalReport::ReportTokenValidFor.to_i
    token = begin
      SignedJwt.create_access_token(grant.user,
        client_id: client.app_id,
        capabilities: capabilities,
        context: grant.context,
        audiences: [APP_CONFIG[:site_url], *audiences].uniq,
        expires_in: ttl)
    rescue SignedJwt::Error => e
      Rails.logger.error("OAuth token: could not sign a scoped token for #{client.app_id}: #{e.message}")
      return oauth_error("server_error", 500)
    end
    return oauth_error("invalid_grant", 400) unless AccessGrant.where(id: grant.id).where.not(code: nil).delete_all == 1
    response.headers["Cache-Control"] = "no-store"
    render json: { access_token: token, token_type: "Bearer", expires_in: ttl, scope: capabilities.join(" ") }
  end

  def issue_opaque_access_token(grant)
    return oauth_error("invalid_grant", 400) unless grant.spend_code!
    grant.start_expiry_period!
    response.headers["Cache-Control"] = "no-store"
    render json: { access_token: grant.access_token, token_type: "bearer", expires_in: AccessGrant::ExpireTime.to_i }
  end

  def oauth_error(error, status)
    response.headers["Cache-Control"] = "no-store"
    render json: { error: error }, status: status
  end

  public

  def failure
    render :plain => "ERROR: #{params[:message]}"
  end

  def user
    hash = {
      :provider => 'concord_id',
      :id => current_user.id.to_s,
      :info => {
        :email      => current_user.email,
      },
      :extra => {
        :first_name => current_user.first_name,
        :last_name  => current_user.last_name,
        :full_name  => current_user.name,
        :username   => current_user.login,
        :user_id    => current_user.id,
        :roles      => current_user.role_names,
        :domain     => request.host_with_port
      }
    }

    render :json => hash.to_json
  end

  # Incase, we need to check timeout of the session from a different application!
  # This will be called ONLY if the user is authenticated and token is valid
  # Extend the UserManager session
  def isalive
    warden.set_user(current_user, :scope => :user)
    response = { 'status' => 'ok' }

    respond_to do |format|
      format.any { render :json => response.to_json }
    end
  end
end
