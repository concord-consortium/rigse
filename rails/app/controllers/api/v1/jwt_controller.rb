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

  def can_access_user(user, target_user_id, resource_link_id)
    return false if user.blank?

    return true if user.has_role?('manager','admin','researcher')

    # Ideally the following logic would be used:
    #
    # If the user is a project admin
    # - is the target user a teacher in one of the admin's cohort
    # - is the target user a student of a teacher in one of the admin's cohorts
    #
    # If the user is a project researcher
    # - is the target user a teacher in one of the researcher's cohorts
    # - is the target user a student with a permission from one of the researcher's projects
    #
    # However we only currently need to support students with permission forms so that is the
    # only part of this logic we'll implement.
    # So we need to get all of the projects the current user is a project admin or researcher of
    # Then get all of their permission_forms
    # Then see if the target_user has any of those permission forms.
    # This is all done in a single SQL query to keep this fast since a lot of JWTs might be
    # requested

    # Find all students through the users's projects and then that project's permission_forms
    user_permission_form_students =
      user.project_users.joins(project: {permission_forms: {portal_student_permission_forms: :portal_student}})

    # In practice project_users (admin_project_users table) is only used for project admins and researchers
    # But to be safe we make sure the project_user is one of these two types
    only_admin_or_researcher_projects =
      user_permission_form_students.where("admin_project_users.is_admin = true OR (admin_project_users.is_researcher = true AND (expiration_date IS NULL OR expiration_date > ?))", Date.today)

    # Finally check if there is a portal_student with the target_user_id
    return true if only_admin_or_researcher_projects.where(portal_students: {user_id: target_user_id}).exists?
    # This active record turns into something like:
    # SELECT  1 AS one
    # FROM `admin_project_users`
    # INNER JOIN `admin_projects` ON `admin_projects`.`id` = `admin_project_users`.`project_id`
    # INNER JOIN `portal_permission_forms` ON `portal_permission_forms`.`project_id` = `admin_projects`.`id`
    # INNER JOIN `portal_student_permission_forms` ON `portal_student_permission_forms`.`portal_permission_form_id` = `portal_permission_forms`.`id`
    # INNER JOIN `portal_students` ON `portal_students`.`id` = `portal_student_permission_forms`.`portal_student_id`
    # WHERE `admin_project_users`.`user_id` = 1
    #   AND (admin_project_users.is_admin = true OR admin_project_users.is_researcher = true)
    #   AND `portal_students`.`user_id` = 8 LIMIT 1

    # A user is allowed access if they are a project researcher linked to the student via a specific path:
    # Project -> Cohort -> Teacher -> Class -> Offering -> Student.
    return true if Portal::Offering.find_by(id: resource_link_id)&.clazz&.then do |clazz|
      user.is_researcher_for_clazz?(clazz) && clazz.students.exists?(user_id: target_user_id)
    end
  end

  def handle_initial_auth
    user, role = check_for_auth_token(params)

    if role
      learner = role[:learner]
      teacher = role[:teacher]
    end

    # FIXME: there is inconsiency here
    # When the user is a teacher, but the auth token (grant) doesn't have the teacher set,
    # the returned teacher here will be nil, unless a valid resource_link_id is passed in.

    resource_link_id = params[:resource_link_id]
    if resource_link_id
      if user.portal_student
        # if there is a valid resource_link_id override any learner that has been
        # found in the auth token
        # FIXME: if this user is a student of this resource_link, but they haven't run it
        # yet, they won't have a learner, but they should still have access to it
        learner = user.portal_student.learners.where(offering_id: resource_link_id).first
        if learner.blank?
          raise StandardError, "current student does not have this resource_link_id"
        end

      elsif user.portal_teacher && user.portal_teacher.offerings.where(id: resource_link_id).exists?
        # We check to make sure the resource_link_id is valid here
        # We override the teacher from the auth token (if there even was one)
        teacher = user.portal_teacher

      else
        # This case is really for only for firebase JWTs, there isn't a use case for admins or
        # researchers needing portal JWTs for specific classes or students.

        # This is a user that isn't a student or teacher of this offering, and they provided
        # a resource_link_id
        # In this case they also have to provide a target_user_id to indicate which
        # student or teacher of resource_link they want access to.
        if params[:target_user_id].blank?
          raise StandardError, "When the resource_link_id is sent and the user is not a" +
            "student or teacher of this resource link, a target_user_id param is required."
        end

        if !can_access_user(user, params[:target_user_id], resource_link_id)
          raise StandardError, "Current user does not have permission to view target user."
        end

        # If the auth token included a teacher or student in it, we override them since
        # we are going to use generic user access at this point
        teacher = nil
        learner = nil
      end
    end

    [user, learner, teacher]
  end

  def jwt_user_id(user)
    site_url_without_trailing_slash = APP_CONFIG[:site_url].sub(/\/$/,'')
    site_url_without_trailing_slash + polymorphic_path(user)
  end

  public
  def portal
    user, learner, teacher = handle_initial_auth

    claims = {}
    if params[:researcher] == "true"
      # Note: no check is done to see if the user is a researcher for any projects.
      # The researcher user_type is used only by clients to know what type of JWT they have
      # and all requests to the portal using the JWT are checked for permissions using the user_id
      # which will check if the user has permissions to access the data.
      # These JWTs are used currently only by generated links in reports and those links may
      # be used by people who are not researchers but have access to the data as project admins
      # or site admins.
      claims = {
        :domain => root_url,
        :user_type => "researcher",
        :user_id => url_for(user),
        :first_name => user.first_name,
        :last_name => user.last_name
      }
    elsif learner
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

    # Firebase auth rules expect all the claims to be in a sub-object named "claims".
    # All the new properties should go there. Other apps can still read them.
    sub_claims = {
      platform_id: APP_CONFIG[:site_url],
      platform_user_id: user.id,
      user_id: jwt_user_id(user)
    }
    claims = {
      claims: sub_claims
    }

    if params[:researcher] == "true"
      if !params[:class_hash].present?
        raise StandardError, "A class_hash is required for researcher access"
      end
      clazz = Portal::Clazz.find_by_class_hash(params[:class_hash])
      if !clazz
        raise StandardError, "A class with the requested class_hash does not exist"
      end
      if !user.is_researcher_for_clazz?(clazz)
        raise StandardError, "As a researcher you do not have access to the requested class_hash"
      end
      class_hash = params[:class_hash]

      sub_claims.merge!({
        user_type: "researcher",
        class_hash: class_hash,
        # The offering_id is not added to the claims because we don't want to restrict the
        # researcher to just this one offering in the class.
      })

    elsif learner
      offering = learner.offering

      sub_claims.merge!({
        user_type: "learner",
        class_hash: offering.clazz.class_hash,
        offering_id: offering.id
      })

      # Depreciated, used by some CC client apps. Do not add more data here, you should
      # add it to sub_claims so the Firebase auth rules can read the properties.
      claims.merge!({
        domain: root_url,
        externalId: learner.id,
        returnUrl: learner.remote_endpoint_url,
        logging: offering.clazz.logging || offering.runnable.logging,
        domain_uid: user.id,
        class_info_url: offering.clazz.class_info_url(request.protocol, request.host_with_port)
      })
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
        offering = Portal::Offering.find(params[:resource_link_id])
        class_hash = offering.clazz.class_hash
      end

      sub_claims.merge!({
        user_type: "teacher",
        class_hash: class_hash,
        # The offering_id is not added to the claims because we don't want to restrict the
        # teacher to just this one offering.
      })

      # Depreciated, used by some CC client apps. Do not add more data here, you should
      # add it to sub_claims so the Firebase auth rules can read the properties.
      claims.merge!({
        domain: root_url,
        domain_uid: user.id,
      })
    else

      sub_claims.merge!({
        user_type: "user",
      })

      resource_link_id = params[:resource_link_id]
      target_user_id = params[:target_user_id]

      # The resource_link_id and target_user_id params were already verified in the
      # handle_initial_auth method
      # If resource_link_id is set but target_user_id is not, the handle_initial_auth will
      # raise an exception
      if resource_link_id && target_user_id

        offering = Portal::Offering.find(resource_link_id)
        class_hash = offering.clazz.class_hash
        sub_claims.merge!({
          class_hash: class_hash,
          offering_id: offering.id,
          # Any systems granting access based on this target_user_id claim should scope it to the
          # class_hash and or offering_id so the main user doesn't gain access to all of the target user's
          # data. Our policies don't always restrict access like this, but they should when possible.
          target_user_id: target_user_id.to_i
        })
      end

    end

    # the firebase uid must be between 1-36 characters and unique across all portals, MD5 yields a 32 byte string
    uid = Digest::MD5.hexdigest(jwt_user_id(user))

    render status: 201, json: {token: SignedJWT::create_firebase_token(uid, params[:firebase_app], 3600, claims)}
  end

end
