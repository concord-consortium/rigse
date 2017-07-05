class AuthenticationsController < Devise::OmniauthCallbacksController

  def schoology
    generic_oauth
  end

  def google
    generic_oauth
  end

  private

  def generic_oauth
    omniauth = request.env["omniauth.auth"]
    if extra = omniauth.extra
      if extra.username.present?
        #
        # Handle Schoology oauth data.
        #
        session[:portal_username] = extra.username
        session[:portal_user_id]  = extra.user_id
        session[:portal_domain]   = extra.domain
      else
        #
        # Handle google oauth data
        #
        parts = omniauth.info.email.split('@')
        session[:portal_username] = parts[0]
        session[:portal_user_id]  = omniauth.info.uid
        session[:portal_domain]   = parts[1]            # What is domain?
                                                        # In this case it
                                                        # effectively stores 
                                                        # the email....?
      end
      #
      # For teachers we should set a valid email after creating
      # the teacher user.
      #
      session[:omniauth_email]  = omniauth.info.email
    end
    begin
      @user = User.find_for_omniauth(omniauth, current_user)
      @user.require_portal_user_type = !current_visitor.has_portal_user_type?
      sign_in_and_redirect @user, :event => :authentication
    rescue => e
      set_flash_message :alert, :failure, kind: OmniAuth::Utils.camelize(env["omniauth.strategy"].name), reason: "a user with that email from that provider already exists. #{e.message}"
      redirect_to after_omniauth_failure_path_for(resource_name)
    end
  end
end
