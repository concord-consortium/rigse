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

  def projects
    authorize Portal::PermissionForm
    projects = policy_scope(Admin::Project)
    filtered_projects = projects.select do |project|
      current_user.can_manage_permission_forms?(project)
    end
    render json: filtered_projects
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
        permission_forms: policy_scope(student.permission_forms).select(:id, :name, :is_archived).map do |form|
          {
            id: form.id,
            name: form.name,
            is_archived: form.is_archived
          }
        end
      }
    end

    render json: permission_forms_data
  end

  # POST /api/v1/permission_forms/bulk_update
  # Accepted params:
  #   - class_id
  #   - list of student IDs
  #   - list of permission form IDs to add
  #   - list of permission form IDs to remove
  def bulk_update
    class_id = params[:class_id]
    student_ids = params[:student_ids]
    add_permission_form_ids = params[:add_permission_form_ids] || []
    remove_permission_form_ids = params[:remove_permission_form_ids] || []

    # Verify that the specified class exists
    clazz = Portal::Clazz.find(class_id)

    # Ensure user has authorization for the specified class
    authorize clazz, :class_permission_forms?

    # Fetch the students that belong to the specified class
    students = clazz.students.where(id: student_ids).includes(:permission_forms)

    # Verify that all specified student IDs belong to the class
    if students.length != student_ids.length
      render json: { error: "Some students do not belong to the specified class" }, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      students.each do |student|
        # Add permission forms
        add_permission_form_ids.each do |form_id|
          permission_form = Portal::PermissionForm.find(form_id)
          next if student.permission_forms.exists?(form_id)
          authorize permission_form, :update?
          student.permission_forms << permission_form
        end

        # Remove permission forms
        remove_permission_form_ids.each do |form_id|
          permission_form = Portal::PermissionForm.find(form_id)
          if student.permission_forms.exists?(form_id)
            authorize permission_form, :update?
            student.permission_forms.delete(permission_form)
          end
        end
      end
    end

    render json: { message: "Bulk update successful" }
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def permission_form_params
    params.require(:permission_form).permit(:name, :project_id, :url, :is_archived)
  end
end
