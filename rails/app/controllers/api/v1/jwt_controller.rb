class API::V1::JwtController < API::APIController

  require 'digest/md5'
  skip_before_action :verify_authenticity_token

  # use exceptions to return errors
  # instead of directly calling APIController#error
  rescue_from StandardError, with: :error_400
  rescue_from SignedJWT::Error, with: :error_500

  private
  def error_400(e)
    error(e.message, 400)
  end

  def error_500(e)
    error(e.message, 500)
  end

  def add_admin_claims(user, claims)
    if (user.has_role? 'admin')
      claims[:admin] = 1
    else
      claims[:admin] = -1
    end
    claims[:project_admins] = []
    user.project_users.each do |p|
      if(p.is_admin)
        claims[:project_admins].push(p.project_id)
      end
    end
  end

  def handle_initial_auth
    user, role = check_for_auth_token(params)

    if role
      learner = role[:learner]
      teacher = role[:teacher]
    end

    offering_id = params[:resource_link_id]
    if offering_id
      if user.portal_student
        # if there is a valid resource_link_id override any learner that has been
        # found in the auth token
        learner = user.portal_student.learners.where(offering_id: offering_id).first
        if learner.blank?
          raise StandardError, "current student does not have this resource_link_id"
        end
      elsif user.portal_teacher
        # We check to make sure the resource_link_id is valid here
        # For teachers the usage of it happens later in the code.
        if user.portal_teacher.offerings.where(id: offering_id).exists?
          teacher = user.portal_teacher
        else
          raise StandardError, "current teacher has not assigned this resource_link_id"
        end
      else
        raise StandardError, "resource_link_id requires a student or teacher user"
      end
    end

    # FIXME: there is inconsiency here
    # When the user is a teacher, but the auth token (grant) doesn't have the teacher set,
    # the returned teacher here will be nil, unless a valid resource_link_id is passed in.

    [ user, learner, teacher ]
  end

  public
  def portal
    user, learner, teacher = handle_initial_auth

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
    add_admin_claims(user,claims)

    render status: 201, json: {token: SignedJWT::create_portal_token(user, claims, 3600)}
  end


  # POST api/v1/jwt/firebase as a logged in user, or
  # GET  api/v1/jwt/firebase?firebase_app=abc with a valid bearer token
  def firebase
    user, learner, teacher = handle_initial_auth

    raise StandardError, "Missing firebase_app parameter" if params[:firebase_app].blank?

    claims = {}
    if learner
      offering = learner.offering
      claims = {
        # Firebase auth rules expect all the claims to be in a sub-object named "claims".
        # All the new properties should go there. Other apps can still read them.
        :claims => {
          :platform_id => APP_CONFIG[:site_url],
          :platform_user_id => user.id,
          :user_type => "learner",
          :user_id => url_for(user),
          :class_hash => offering.clazz.class_hash,
          :offering_id => offering.id
        },
        # Depreciated, used by some CC client apps. Do not add more data here, it's better to add that to claims
        # object above, as then Firebase auth rules can read these properties too.
        :domain => root_url,
        :externalId => learner.id,
        :returnUrl => learner.remote_endpoint_url,
        :logging => offering.clazz.logging || offering.runnable.logging,
        :domain_uid => user.id,
        :class_info_url => offering.clazz.class_info_url(request.protocol, request.host_with_port),
      }
    elsif teacher

      # add a class_hash claim if a class_hash or resource_link_id param is present
      class_hash = nil
      if params[:class_hash].present?
        # verify the optional passed class_hash is valid
        class_hashes = teacher.clazzes.map {|c| c.class_hash}
        if !class_hashes.include? params[:class_hash]
          raise StandardError, "Teacher does not have a class with the requested class_hash"
        end
        class_hash = params[:class_hash]
      elsif params[:resource_link_id].present?
        # The resource_link_id param was already verified in the handle_initial_auth method
        # The offering_id is not added to the claims because we don't want to restrict the
        # teacher to just this one offering.
        offering = Portal::Offering.find(params[:resource_link_id])
        class_hash = offering.clazz.class_hash
      end

      claims = {
        # Firebase auth rules expect all the claims to be in a sub-object named "claims".
        # All the new properties should go there. Other apps can still read them.
        :claims => {
          :platform_id => APP_CONFIG[:site_url],
          :platform_user_id => user.id,
          :user_type => "teacher",
          :user_id => url_for(user),
          :class_hash => class_hash
        },
        # Depreciated, used by some CC client apps. Do not add more data here, it's better to add that to claims
        # object above, as then Firebase auth rules can read these properties too.
        :domain => root_url,
        :domain_uid => user.id,
      }
    else
      claims = {
        # Firebase auth rules expect all the claims to be in a sub-object named "claims".
        # All the new properties should go there. Other apps can still read them.
        :claims => {
          :platform_id => APP_CONFIG[:site_url],
          :platform_user_id => user.id,
          :user_type => "user",
          :user_id => url_for(user)
        }
      }
      # since the generic user case was added after domain and domain_uid where deprecated they are not set here
    end

    # the firebase uid must be between 1-36 characters and unique across all portals, MD5 yields a 32 byte string
    uid = Digest::MD5.hexdigest(url_for(user))

    render status: 201, json: {token: SignedJWT::create_firebase_token(uid, params[:firebase_app], 3600, claims)}
  end

end
