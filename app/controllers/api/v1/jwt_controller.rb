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
      learner = grant.learner
    else
      return error('You must be logged in to use this endpoint') if !current_user
      user = current_user
    end

    return error('Missing firebase_app parameter') if params[:firebase_app].blank?

    claims = {}
    if learner
      offering = learner.offering
      claims = {
        :domain => root_url,
        :externalId => learner.id,
        :returnUrl => learner.remote_endpoint_url,
        :logging => offering.clazz.logging || offering.runnable.logging,
        :domain_uid => user.id,
        :class_info_url => offering.clazz.class_info_url(request.protocol, request.host_with_port)
      }
    end

    begin
      render status: 201, json: {token: SignedJWT::create_firebase_token(user, params[:firebase_app], 3600, claims)}
    rescue Exception => e
      error(e.message, 500)
    end
  end

end
