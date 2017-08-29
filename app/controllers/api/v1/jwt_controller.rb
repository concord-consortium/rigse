class API::V1::JwtController < API::APIController

  # POST api/v1/jwt/firebase as a logged in user, or
  # GET  api/v1/jwt/firebase?firebase_app=abc with a valid bearer token
  def firebase
    header = request.headers["Authorization"]
    if header && header =~ /^Bearer (.*)$/
      token = $1
      grant = AccessGrant.find_by_access_token(token)

      return error('Cannot find AccessGrant for token #{token}') if !grant
      return error('AccessGrant has expired') if grant.access_token_expires_at < Time.now

      user = grant.user
    else
      return error('You must be logged in to use this endpoint') if current_visitor.anonymous?
      user = current_visitor
    end

    return error('Missing firebase_app parameter') if params[:firebase_app].blank?

    begin
      render status: 201, json: {token: SignedJWT::create_firebase_token(user, params[:firebase_app])}
    rescue Exception => e
      error(e.message, 500)
    end
  end

end
