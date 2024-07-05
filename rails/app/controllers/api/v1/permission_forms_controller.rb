class API::V1::PermissionFormsController < API::APIController

  # GET /api/v1/permission_forms/index
  def index
    authorize Portal::PermissionForm
    permission_forms = management_policy_scope(Portal::PermissionForm)

    permission_forms_with_permissions = permission_forms.map do |form|
      permission_form_hash(form).merge(can_delete: Pundit.policy(current_user, form).destroy?)
    end

    render json: permission_forms_with_permissions
  end

  def create
    authorize Portal::PermissionForm
    permission_form = Portal::PermissionForm.new(permission_form_params)
    if permission_form.save
      render :json => permission_form
    else
      render :json => { :errors => permission_form.errors }, :status => 422
    end
  end

  def update
    permission_form = Portal::PermissionForm.find(params[:id])
    authorize permission_form
    if permission_form.update(permission_form_params)
      render :json => permission_form
    else
      render :json => { :errors => permission_form.errors }, :status => 422
    end
  end

  def destroy
    permission_form = Portal::PermissionForm.find(params[:id])
    authorize permission_form
    permission_form.destroy
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
      return render json: {
        teachers: [],
        total_teachers_count: 0,
        limit_applied: false
      }
    end

    # Set default limit to 50 if not provided
    limit = params[:limit].present? ? params[:limit].to_i : 50

    # Use sanitize_sql_like to escape special characters
    value = "%#{ActiveRecord::Base.sanitize_sql_like(params[:name])}%"

    base_query = Pundit.policy_scope(current_user, Portal::Teacher)
      .joins(:user)
      .where("users.login LIKE :value OR users.first_name LIKE :value OR users.last_name LIKE :value OR users.email LIKE :value", value: value)
      .order("users.first_name, users.last_name")

    # Get total count of matching teachers
    total_teachers_count = base_query.count

    # Get the limited set of teachers
    teachers = base_query.limit(limit)

    teacher_data = teachers.map do |teacher|
      {
        id: teacher.id,
        name: teacher.user.name,
        email: teacher.user.email,
        login: teacher.user.login
      }
    end

    result = {
      teachers: teacher_data,
      total_teachers_count: total_teachers_count,
      limit_applied: total_teachers_count > limit
    }

    render json: result
  end

  def class_permission_forms
    clazz = Portal::Clazz.find(params[:class_id])

    authorize clazz, :class_permission_forms?

    students = clazz.students.includes(:permission_forms, :user).order("users.first_name, users.last_name")

    permission_forms_data = students.map do |student|
      {
        id: student.id,
        name: student.user.name,
        login: student.user.login,
        permission_forms: management_policy_scope(student.permission_forms).map do |form|
          permission_form_hash(form)
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
  end

  private

  # Default scope is too wide, we need extra filtering for project researchers.
  # Pundit doesn't seem to be flexible enough to handle this, so we need to do it manually.
  def management_policy_scope(scope)
    if current_user.has_role?('admin')
      # Admin users have access to all projects
      scope.all
    elsif current_user.is_project_admin? || current_user.is_project_researcher?
      admin_project_ids = current_user.admin_for_projects.select(:id)
      manageable_project_ids = current_user._project_user_researchers.where(can_manage_permission_forms: true).select(:project_id)
      scope.where("project_id IN (?) OR project_id IN (?)", admin_project_ids, manageable_project_ids)
    else
      # No access for users without the relevant roles
      scope.none
    end
  end

  def permission_form_hash(permission_form)
    {
      id: permission_form.id,
      name: permission_form.name,
      project_id: permission_form.project_id,
      url: permission_form.url,
      is_archived: permission_form.is_archived
    }
  end

  def permission_form_params
    params.require(:permission_form).permit(:name, :project_id, :url, :is_archived)
  end
end
