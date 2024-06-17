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

  def update
    @permission_form = Portal::PermissionForm.find(params[:id])
    authorize @permission_form
    if @permission_form.update(permission_form_params)
      render :json => @permission_form
    else
      render :json => { :errors => @permission_form.errors }, :status => 422
    end
  end

  def destroy
    @permission_form = Portal::PermissionForm.find(params[:id])
    authorize @permission_form
    @permission_form.destroy
    render :json => { :message => "Permission form deleted" }
  end

  private

  def permission_form_params
    params.require(:permission_form).permit(:name, :project_id, :url, :is_archived)
  end
end
