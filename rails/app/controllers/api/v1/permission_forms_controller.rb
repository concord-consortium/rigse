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

  def search_teachers
    authorize Portal::PermissionForm

    if params[:name].blank?
      return render json: []
    end

    # Use sanitize_sql_like to escape special characters
    value = "%#{ActiveRecord::Base.sanitize_sql_like(params[:name])}%"

    teachers = Pundit.policy_scope(current_user, Portal::Teacher)
      .joins(:user)
      .where("users.login LIKE :value OR users.first_name LIKE :value OR users.last_name LIKE :value OR users.email LIKE :value", value: value)

    teacher_data = teachers.map do |teacher|
      {
        id: teacher.id,
        name: teacher.user.name,
        email: teacher.user.email,
        login: teacher.user.login
      }
    end

    render json: teacher_data
  end

  def class_permission_forms
    clazz = Portal::Clazz.find(params[:class_id])

    authorize clazz, :class_permission_forms?

    students = clazz.students.includes(:permission_forms)

    permission_forms_data = students.map do |student|
      {
        id: student.id,
        name: student.user.name,
        login: student.user.login,
        permission_forms: student.permission_forms.select(:id, :name).map do |form|
          {
            id: form.id,
            name: form.name
          }
        end
      }
    end

    render json: permission_forms_data
  end

  private

  def permission_form_params
    params.require(:permission_form).permit(:name, :project_id, :url, :is_archived)
  end
end
