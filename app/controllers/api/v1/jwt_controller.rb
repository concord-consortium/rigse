class API::V1::JwtController < API::APIController

  require 'digest/md5'
  skip_before_filter :verify_authenticity_token

  def portal
    user, role = check_for_auth_token()
    return if !user

    if role
      learner = role[:learner]
      teacher = role[:teacher]
    end

    claims = {}
    if learner
      offering = learner.offering
      claims = {
        :domain => root_url,
        :user_type => "learner",
        :user_id => url_for(user),
        :learner_id => learner.id,
        :class_info_url => offering.clazz.class_info_url(request.protocol, request.host_with_port),
        :offering_id => offering.id
      }
    elsif teacher
      claims = {
        :domain => root_url,
        :user_type => "teacher",
        :user_id => url_for(user),
        :teacher_id => teacher.id
      }
    end

    begin
      render status: 201, json: {token: SignedJWT::create_portal_token(user, claims, 3600)}
    rescue Exception => e
      error(e.message, 500)
    end
  end


  # POST api/v1/jwt/firebase as a logged in user, or
  # GET  api/v1/jwt/firebase?firebase_app=abc with a valid bearer token
  def firebase
    user, role = check_for_auth_token()
    return if !user

    if role
      learner = role[:learner]
      teacher = role[:teacher]
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
        :class_info_url => offering.clazz.class_info_url(request.protocol, request.host_with_port),
        :claims => { # need claims sub-namespace for firebase auth rules
          :user_type => "learner",
          :user_id => url_for(user),
          :class_hash => offering.clazz.class_hash,
          :offering_id => offering.id
        }
      }
    elsif teacher
      # verify if the optional passed class_hash is valid
      if params[:class_hash].present?
        class_hashes = teacher.clazzes.map {|c| c.class_hash}
        if !class_hashes.include? params[:class_hash]
          return error('Teacher does not have a class with the requested class_hash')
        end
      end

      claims = {
        :domain => root_url,
        :domain_uid => user.id,
        :claims => { # need claims sub-namespace for firebase auth rules
          :user_type => "teacher",
          :user_id => url_for(user),
          :class_hash => params[:class_hash]
        }
      }
    end

    # the firebase uid must be between 1-36 characters and unique across all portals, MD5 yields a 32 byte string
    uid = Digest::MD5.hexdigest(url_for(user))

    begin
      render status: 201, json: {token: SignedJWT::create_firebase_token(uid, params[:firebase_app], 3600, claims)}
    rescue Exception => e
      error(e.message, 500)
    end
  end

end
