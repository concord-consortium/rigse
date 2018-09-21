class API::APIController < ApplicationController

  rescue_from Pundit::NotDefinedError, with: :pundit_user_not_authorized

  protected

  def pundit_user_not_authorized(exception)
    render status: 403, json: {
      success: false,
      message: exception.message
    }
  end

  public

  def show
    raise Pundit::NotDefinedError, "Show not configured for this resource"
  end

  def create
    raise Pundit::NotDefinedError, "create not configured for this resource"
  end

  def update
    raise Pundit::NotDefinedError, "update not configured for this resource"
  end

  def index
    raise Pundit::NotDefinedError,  "index not configured for this resource"
  end

  def destroy
    raise Pundit::NotDefinedError, "destroy not configured for this resource"
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
          raise Pundit::NotAuthorizedError, 'AccessGrant has expired'
        end

      # peer to peer authentication based on app_secret is available if the learner id is passed
      elsif params[:learner_id_or_key]
        learner = Portal::Learner.find_by_id_or_key(params[:learner_id_or_key])
        if learner
          peer = Client.find_by_app_secret(token)
          if peer
            return [learner.student.user, {:learner => learner, :teacher => nil}]
          else
            raise Pundit::NotAuthorizedError, "Cannot find requested peer token" # don't leak token value in error
          end
        else
          raise Pundit::NotAuthorizedError, "Cannot find learner with id or key of '#{params[:learner_id_or_key]}'"
        end

      else
        raise Pundit::NotAuthorizedError, "Cannot find AccessGrant for token '#{token}'"
      end

    elsif header && header =~ /^Bearer\/JWT (.*)$/i
      portal_token = $1
      # if invalid this will raise a SignedJWT::Error which is a subclass of StandardError that the caller should be listening for
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
        raise Pundit::NotAuthorizedError, 'User in token not found'
      end

    elsif current_user
      return [current_user, nil]
    else
      raise Pundit::NotAuthorizedError, 'You must be logged in to use this endpoint'
    end
  end
end
