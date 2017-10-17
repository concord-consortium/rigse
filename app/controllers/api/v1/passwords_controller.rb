class API::V1::PasswordsController < API::APIController

    #
    # Route /api/v1/passwords/reset_password
    #
    def reset_password

        login_or_email = params[:login_or_email]

        #
        # Try to find user by login
        #
        user = User.find_by_login(login_or_email)
    
        if user.nil?
            #
            # Try to find user by email
            #
            user = User.find_by_email(login_or_email)
        end
      
        #
        # Could not find user by login or email?
        #
        if user.nil?
            message = "Cannot find user or email."
            render status: 403, :json => { :message => message }
            return
        end
    
        #
        # Check if user is an SSO user.
        #
        if user.is_oauth_user?
            provider    = user.authentications[0].provider.titleize
            message     = "This is a #{provider} authenticated account. " <<
                            "Please use #{provider} to make password changes."
            render status: 403, :json => { :message => message }
            return
        end
    
        @password = Password.new(:user => user, :email => user.email)
        if @password.save
            PasswordMailer.forgot_password(@password).deliver
            message =   
                "A link to change your password has been sent " <<
                "to #{@password.email}."
            render status: 200, :json => { :message => message }
            return
        else
            message =   
                "This account has not set a valid email address. " <<
                "Please contact your school manager to access your account."
            render status: 403, :json => { :message => message }
            return
        end
    
    end

end
