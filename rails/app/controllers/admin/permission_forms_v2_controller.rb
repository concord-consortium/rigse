class Admin::PermissionFormsV2Controller < ApplicationController

  def not_authorized_error_message
    super({resource_type: 'permission form'})
  end

  def index
    authorize Portal::PermissionForm, :permission_forms_v2_index?
  end
end
