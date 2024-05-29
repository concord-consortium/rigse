class API::V1::PermissionFormsController < API::APIController

  public

  def index
    @permission_forms = policy_scope(Portal::PermissionForm)
    render :json => @permission_forms
  end
end
