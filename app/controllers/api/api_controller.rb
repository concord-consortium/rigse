class API::APIController < ApplicationController

  protected

  def pundit_user_not_authorized(exception)
    render status: 403, json: {
      success: false,
      message: 'Not authorized'
    }
  end

  public

  def error(message, status = 400)
    render :json =>
      {
        :response_type => "ERROR",
        :message => message
      },
      :status => status
  end

  def show
    error("Show not configured for this resource")
  end

  def create
    error("create not configured for this resource")
  end

  def update
    error("update not configured for this resource")
  end

  def index
    error("index not configured for this resource")
  end

  def destroy
    error("destroy not configured for this resource")
  end

  def check_for_auth_token
    header = request.headers["Authorization"]
    if header && header =~ /^Bearer (.*)$/i
      token = $1
      grant = AccessGrant.find_by_access_token(token)

      if !grant
        error('Cannot find AccessGrant for token #{token}')
        return
      end
      if grant.access_token_expires_at < Time.now
        error('AccessGrant has expired')
        return
      end

      role = {
        :learner => grant.learner,
        :teacher => grant.teacher
      }

      return [grant.user, role]
    elsif header && header =~ /^Bearer\/JWT (.*)$/i
      portal_token = $1
      begin
        decoded_token = SignedJWT::decode_portal_token(portal_token)
      rescue Exception => e
        error(e.message)
        return
      end
      data = decoded_token[:data]

      user = User.find_by_id(data["uid"])
      if !user
        error('User in token not found')
        return
      end

      role = {
        :learner => data["user_type"] == "learner" ? Portal::Learner.find_by_id(data["learner_id"]) : nil,
        :teacher => data["user_type"] == "teacher" ? Portal::Teacher.find_by_id(data["teacher_id"]) : nil
      }

      return [user, role]
    elsif !current_user
      error('You must be logged in to use this endpoint')
      return
    else
      return [current_user, nil]
    end
  end
end
