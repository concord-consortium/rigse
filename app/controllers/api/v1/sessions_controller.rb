class API::V1::SessionsController < Devise::SessionsController

  skip_before_filter :verify_authenticity_token, :only => [:create]

  respond_to :json

  #
  # Create a new session
  #
  # The #create method (through the /api/v1/users/sign_in route) receives:
  # {"user"=>{"login"=>"login", "password"=>"password"}}
  #
  def create

    username = params[:user][:login]
    password = params[:user][:password]

    user = User.find_by_login(username)

    #
    # Would be nice to use warden.authenticate! which returns the
    # authenticated user, but if it fails it responds with its own json.
    #
    # So cannot use:
    # warden.custom_failure!
    # self.resource = warden.authenticate!(auth_options)
    #

    if user && user.valid_password?(password)

      resource = user
      sign_in(resource_name, resource)

      render status: 200, :json => { :message => "Login success." }

    else
      render status: 401, :json => { :message => "Login failed." }

    end

  end

end
