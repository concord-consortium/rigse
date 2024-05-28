class Admin::PermissionFormsV2Controller < ApplicationController

  protected

  def not_authorized_error_message
    super({resource_type: 'permission form'})
  end

  def index
    authorize Portal::PermissionForm
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @permission_forms = policy_scope(Portal::PermissionForm)
    form = TeacherSearchForm.new(params[:form])
    @teachers = form.search current_visitor
    @projects = policy_scope(Admin::Project).order("name ASC")
    @permission_forms = policy_scope(Portal::PermissionForm)
  end
end
