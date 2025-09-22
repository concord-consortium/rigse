class Report::UserController < ApplicationController

  protected

  def not_authorized_error_message
    super({resource_type: 'report user'})
  end

  public

  def index
    authorize Report::User
    render layout: "application"
  end
end
