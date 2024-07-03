class Admin::PermissionFormsController < ApplicationController

  def not_authorized_error_message
    super({resource_type: 'permission form'})
  end

  def index
    authorize Portal::PermissionForm
  end
end
