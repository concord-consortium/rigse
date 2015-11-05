class AuthenticationsController < Devise::OmniauthCallbacksController
  def schoology
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Authentication
    # authorize @authentication
    # authorize Authentication, :new_or_create?
    # authorize @authentication, :update_edit_or_destroy?
    generic_oauth
  end

  private

  def generic_oauth
    omniauth = request.env["omniauth.auth"]
    if extra = omniauth.extra
      session[:portal_username] = extra.username
      session[:portal_user_id]  = extra.user_id
      session[:portal_domain]   = extra.domain
    end
    begin
      @user = User.find_for_omniauth(omniauth, current_user)
      @user.require_portal_user_type = !current_visitor.has_portal_user_type?
      sign_in_and_redirect @user, :event => :authentication
    rescue
      set_flash_message :alert, :failure, kind: OmniAuth::Utils.camelize(env["omniauth.strategy"].name), reason: "a user with that email from that provider already exists"
      redirect_to after_omniauth_failure_path_for(resource_name)
    end
  end
end
