class AuthenticationsController < Devise::OmniauthCallbacksController

  def schoology
    generic_oauth
  end

  def google
    # Check for a speical 'after_sign_in_path' field in the state parameter.
    # The state parameter might be in the following forms:
    # - nil
    # - abcd1234 (random string)
    # - after_sign_in_path=/somewhere
    # - abcd1234 after_sign_in_path=/somewhere
    # There isn't yet a need for multiple fields in the state, so a separator character
    # between fields hasn't been defined.
    # There is a space between the state defined by the google provider (random string)
    # and the after_sign_in_path field.
    # If more fields need to be added to the state, we'll need a more complex approach.
    # Currently this regex will bring in everything until the end of the state.
    # If we need multiple fields in the state we could:
    # - URL encode the parameter values and separate them by '&'.
    # - switch to a base64 encoded JSON value. 
    if(request.params["state"].present? &&
       request.params["state"].match(/after_sign_in_path=(.*)/))
      # in future versions of rack update_param should be used
      # request.update_param("after_sign_in_path", $1)
      request.params["after_sign_in_path"] = $1
    end
    generic_oauth
  end

  private

  def generic_oauth

    omniauth    = request.env["omniauth.auth"]
    origin      = request.env["omniauth.origin"]

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

      #
      # Return user to omniauth_origin after signup is complete.
      #
      session[:omniauth_origin] = origin

    end
    begin
      @user = User.find_for_omniauth(omniauth, current_user)
      @user.require_portal_user_type = !current_visitor.has_portal_user_type?
      sign_in_and_redirect @user, :event => :authentication
    rescue => e
      # Record this exception so we can figure out what is going wrong
      ExceptionNotifier.notify_exception(
        e,
        env: request.env,
        data: {
          first_name:   auth&.extra&.first_name   || auth&.info&.first_name,
          last_name:    auth&.extra&.last_name    || auth&.info&.last_name
        }
      )
      set_flash_message :alert, :failure, kind: OmniAuth::Utils.camelize(request.env["omniauth.strategy"].name), reason: "a user with that email from that provider already exists. #{e.message}"
      redirect_to after_omniauth_failure_path_for(resource_name)
    end
  end
end
