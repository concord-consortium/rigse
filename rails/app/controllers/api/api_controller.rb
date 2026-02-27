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
    if header && (header =~ /^Bearer\/JWT (.*)$/i || (header =~ /^Bearer (.+\..+)$/i))
      portal_token = $1
      # if invalid this will raise a SignedJwt::Error which is a subclass of StandardError that the caller should be listening for
      # the expiration is checked within the JWT.decode function
      decoded_token = SignedJwt::decode_portal_token(portal_token)
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

    elsif header && header =~ /^Bearer (.*)$/i
      token = $1
      grant = AccessGrant.find_by_access_token(token)

      if grant
        if grant.access_token_expires_at >= Time.now
          return [grant.user, {:learner => grant.learner, :teacher => grant.teacher}]
        else
          raise StandardError, 'AccessGrant has expired'
        end
      else
        raise StandardError, "Cannot find AccessGrant for requested token"
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
end
