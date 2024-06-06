class API::V1::PermissionFormsController < API::APIController

  # GET /api/v1/permission_forms/index
  def index
    @permission_forms = policy_scope(Portal::PermissionForm)
    render :json => @permission_forms
  end

  def create
    authorize Portal::PermissionForm
    @permission_form = Portal::PermissionForm.new(permission_form_params)
    if @permission_form.save
      render :json => @permission_form
    else
      render :json => { :errors => @permission_form.errors }, :status => 422
    end
  end

  private

  def permission_form_params
    params.require(:permission_form).permit(:name, :project_id, :url)
  end
end
