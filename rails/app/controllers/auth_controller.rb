class AuthController < ApplicationController

  before_action :verify_logged_in, :except => [ :access_token,
                                                :login,
                                                :oauth_authorize ]

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

  def oauth_authorize
    if current_user.nil?
      validation = AccessGrant.validate_oauth_authorize(params)
      if (!validation.valid)
        redirect_to validation.error_redirect
        return
      end

      # if the parameters are valid then the validation will have a client
      # we send the clients name to the login box so it can display a helpful name
      app_name = validation.client.name
      redirect_to auth_login_path(after_sign_in_path: request.fullpath, app_name: app_name)
      return
    end

    # Note that we'll get to this point only if user is currently logged in.
    # If user is not logged in, we'll redirect back here after first
    # logging in the user. This redirect happens when in
    # ApplicationController#after_sign_in_path_for
    redirect_to AccessGrant.get_authorize_redirect_uri(current_user, params)
  end

  def access_token
    application = Client.authenticate(params[:client_id], params[:client_secret])

    if application.nil?
      render :json => {:error => "Could not find application"}
      return
    end

    access_grant = AccessGrant.authenticate(params[:code], application.id)
    if access_grant.nil?
      render :json => {:error => "Could not authenticate access code"}
      return
    end

    access_grant.start_expiry_period!
    render :json => {:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => Devise.timeout_in.to_i}
  end

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
