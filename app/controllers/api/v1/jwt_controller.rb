class API::V1::JwtController < API::APIController

  # POST api/v1/jwt/firebase
  def firebase
    return error('You must be logged in to use this endpoint') if !current_user
    return error('Missing firebase_app parameter') if params[:firebase_app].blank?

    begin
      render status: 201, json: {token: SignedJWT::create_firebase_token(current_user, params[:firebase_app])}
    rescue Exception => e
      error(e.message, 500)
    end
  end

end
