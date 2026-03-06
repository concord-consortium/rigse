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
    token = extract_bearer_token(header)

    if token && (header =~ /^Bearer\/JWT/i || SignedJwt.probably_jwt?(token))
      if SignedJwt.portal_token?(token)
        # Portal JWT — decode and authenticate. Errors raise SignedJwt::Error
        # or JWT::ExpiredSignature, which callers should be listening for.
        decoded_token = SignedJwt::decode_portal_token(token)
        data = decoded_token[:data]

        user = User.find_by_id(data["uid"])
        if user
          role = {
            :learner => data["user_type"] == "learner" ? Portal::Learner.find_by_id(data["learner_id"]) : nil,
            :teacher => data["user_type"] == "teacher" ? Portal::Teacher.find_by_id(data["teacher_id"]) : nil
          }
          request.env['portal.auth_strategy'] = 'api_jwt'
          return [user, role]
        else
          raise StandardError, 'User in token not found'
        end
      else
        # Non-portal JWT (e.g., OIDC) — already authenticated by Devise strategy
        if current_user
          return [current_user, nil]
        else
          raise StandardError, 'You must be logged in to use this endpoint'
        end
      end

    elsif token
      # Not a JWT, so treat as an opaque AccessGrant token
      grant = AccessGrant.find_by_access_token(token)

      if grant
        if grant.access_token_expires_at >= Time.now
          request.env['portal.auth_strategy'] = 'api_access_grant'
          request.env['portal.auth_client'] = grant.client&.name
          return [grant.user, {:learner => grant.learner, :teacher => grant.teacher}]
        else
          raise StandardError, 'AccessGrant has expired'
        end
      else
        raise StandardError, "Cannot find AccessGrant for requested token"
      end

    elsif current_user
      request.env['portal.auth_strategy'] = 'api_session'
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

  def require_api_user!
    unless current_user
      error('You must be logged in to use this endpoint', 401)
    end
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
      Rails.logger.warn("API auth failed: #{e.message}, path=#{request.path}")
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

  # Extracts the token value from an Authorization header.
  # Supports both "Bearer/JWT <token>" and "Bearer <token>".
  def extract_bearer_token(header)
    return nil unless header
    if header =~ /^Bearer(?:\/JWT)?\s+(.+)$/i
      $1
    end
  end
end
