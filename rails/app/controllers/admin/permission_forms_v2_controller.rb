class Admin::PermissionFormsV2Controller < ApplicationController

  def not_authorized_error_message
    super({resource_type: 'permission form'})
  end

  def index
    authorize Portal::PermissionForm
    # TODO: figure out why this form not loads
    # form = TeacherSearchForm.new(params[:form])
    @projects = policy_scope(Admin::Project).order("name ASC")
    @permission_forms = policy_scope(Portal::PermissionForm)
  end
end
