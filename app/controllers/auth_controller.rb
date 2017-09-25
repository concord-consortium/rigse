class AuthController < ApplicationController

  before_filter :verify_logged_in, :except => [ :access_token, 
                                                :login,
                                                :oauth_authorize ]

  skip_before_filter :authenticate_user!, :only => [:authorize]  # this is handled by verify_logged_in
  skip_before_filter :verify_authenticity_token, :only => [:access_token]

  def verify_logged_in

    session.delete :sso_callback_params
    session.delete :sso_application

    if current_user.nil?
        redirect_to auth_login_path
    end

  end


  def login
    # Renders a nice login form (views/auth/login.haml).
    # TODO session variables cause weird behaviors try to remove this if possible
    @app_name = session[:sso_application] ? session[:sso_application].name : nil
    @error = flash[:alert]
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
      redirect_path = redirect_uri.to_s

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
        session[:sso_callback_params] = params
        session[:sso_application]     = application
        redirect_to auth_login_path
        return
    end

    AccessGrant.prune!
    access_grant = current_user.access_grants.create({:client => application, :state => params[:state]}, :without_protection => true)
    redirect_to access_grant.redirect_uri_for(params[:redirect_uri])
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
    render :text => "ERROR: #{params[:message]}"
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

  protected

  def application
    @application ||= Client.find_by_app_id(params[:client_id])
  end

end
