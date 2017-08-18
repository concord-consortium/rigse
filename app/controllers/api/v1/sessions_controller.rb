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

    if user && user.valid_password?(password)

      sign_in(resource_name, user)
      render status: 200, :json => { :message => "Login success." }

    else
      render status: 401, :json => { :message => "Login failed." }

    end

  end

end