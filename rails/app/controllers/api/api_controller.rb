class API::APIController < ApplicationController

  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def show
    return error("Show not configured for this resource")
  end

  def create
    return error("create not configured for this resource")
  end

  def update
    return error("update not configured for this resource")
  end

  def index
    return error("index not configured for this resource")
  end

  def destroy
    return error("destroy not configured for this resource")
  end

  def check_for_auth_token(params)
    header = request.headers["Authorization"]
    if header && header =~ /^Bearer (.*)$/i
      token = $1
      grant = AccessGrant.find_by_access_token(token)

      if grant
        if grant.access_token_expires_at >= Time.now
          return [grant.user, {:learner => grant.learner, :teacher => grant.teacher}]
        else
          raise StandardError, 'AccessGrant has expired'
        end

      # peer to peer authentication based on app_secret is available if the learner id is passed
      elsif params[:learner_id_or_key]
        begin
          # find_by_id_or_key uses find! so we need to catch the exception
          # NOTE: we should probably rename it to find_by_id_or_key! so that callers know it
          # generates an exception unlike normal find_by_x methods
          learner = Portal::Learner.find_by_id_or_key(params[:learner_id_or_key])
        rescue
          raise StandardError, "Cannot find learner with id or key of '#{params[:learner_id_or_key]}'"
        end
        peer = Client.find_by_app_secret(token)
        if peer
          return [learner.student.user, {:learner => learner, :teacher => nil}]
        else
          raise StandardError, "Cannot find requested peer token" # don't leak token value in error
        end

      # peer to peer authentication based on app_secret is available if the user id is passed
      elsif params[:user_id]
        user = User.find_by_id(params[:user_id])
        if user
          peer = Client.find_by_app_secret(token)
          if peer
            return [user, {:learner => nil, :teacher => nil}]
          else
            raise StandardError, "Cannot find requested peer token" # don't leak token value in error
          end
        else
          raise StandardError, "Cannot find user with id of '#{params[:user_id]}'"
        end
      else
        # NOTE: token value was removed from error so we don't leak peer tokens
        raise StandardError, "Cannot find AccessGrant for requested token"
      end

    elsif header && header =~ /^Bearer\/JWT (.*)$/i
      portal_token = $1
      # if invalid this will raise a SignedJWT::Error which is a subclass of StandardError that the caller should be listening for
      # the expiration is checked within the JWT.decode function
      decoded_token = SignedJWT::decode_portal_token(portal_token)
      data = decoded_token[:data]

      user = User.find_by_id(data["uid"])
      if user
        role = {
          :learner => data["user_type"] == "learner" ? Portal::Learner.find_by_id(data["learner_id"]) : nil,
          :teacher => data["user_type"] == "teacher" ? Portal::Teacher.find_by_id(data["teacher_id"]) : nil
        }
        return [user, role]
      else
        raise StandardError, 'User in token not found'
      end

    elsif current_user
      return [current_user, nil]
    else
      raise StandardError, 'You must be logged in to use this endpoint'
    end
  end

  protected

  # NOTE: this approach requires you to return from the
  # method to prevent a double render problem. An easy way to do this:
  #  return error(...)
  def error(message, status = 400, details = nil)
    error_body = {
      :success => false,
      :response_type => "ERROR",
      :message => message,
    }
    error_body[:details] = details if details
    render :json => error_body, :status => status
  end

  def pundit_user_not_authorized(exception)
    render status: 403, json: {
      success: false,
      message: 'Not authorized'
    }
  end

  def parameter_missing(exception)
    render status: 400, json: {
      success: false,
      message: exception.message
    }
  end

  def record_not_found(exception)
    render status: 404, json: {
      success: false,
      message: exception.message
    }
  end

  def auth_not_anonymous(params)
    begin
      user, role = check_for_auth_token(params)
    rescue StandardError => e
      return {error: e.message}
    end

    if user.anonymous?
      return {error: 'You must be logged in to use this endpoint'}
    end

    return {user: user, role: role}
  end

  def auth_teacher(params)
    auth = auth_not_anonymous(params)
    return auth if auth[:error]
    user = auth[:user]

    if !user.portal_teacher
      auth[:error] = 'You must be logged in as a teacher to use this endpoint'
    end

    return auth
  end

  def auth_student_or_teacher(params)
    auth = auth_not_anonymous(params)
    return auth if auth[:error]
    user = auth[:user]

    if !user.portal_student && !user.portal_teacher
      auth[:error] = 'You must be logged in as a student or teacher to use this endpoint'
    end

    return auth
  end
end
