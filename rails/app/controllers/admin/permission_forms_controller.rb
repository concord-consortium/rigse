class Admin::PermissionFormsController < ApplicationController

  protected

  def not_authorized_error_message
    super({resource_type: 'permission form'})
  end

  def update_student_permissions(student_id, permission_ids)
    student = Portal::Student.find(student_id)
    return false unless student
    permission_ids ||= []
    permission_ids = [permission_ids].flatten.compact.uniq
    permissions = permission_ids.map { |pid| Portal::PermissionForm.find(pid) }
    student.permission_forms = permissions
    student.save
    return true
  end


  class TeacherSearchForm < Struct.new(:name, :order)

    def initialize(params)
      params ||= {}
      self.name  = params[:name]
      self.order = params[:order] || "last_name"
    end
    def search(current_visitor)
      return [] unless self.name
      value  = "%#{self.name}%"
      where  = "users.login like ? " +
               "or users.first_name like ? " +
               "or users.last_name like ?" +
               "or users.email like ?"
      order  = "users.last_name"
      group  = "users.login"
      if current_visitor.has_role?('manager', 'admin', 'researcher')
        teachers = Portal::Teacher.joins(:user,:clazzes).where(where, value, value, value, value)
      else
        if current_visitor.is_project_admin?
          ids = current_visitor.admin_for_project_teachers.map {|t| t.user_id}
        elsif current_visitor.is_project_researcher?
          ids = current_visitor.researcher_for_project_teachers.map {|t| t.user_id}
        end
        teachers = Portal::Teacher.joins(:user,:clazzes).where("users.id in (?) and (#{where})", ids, value, value, value, value)
      end
      teachers.order(order).group(group).limit(30).map { |t| TeacherView.new(t)}
    end
  end

  class StudentView < Struct.new(:name, :id, :login, :perms)
    def initialize(portal_student)
      user          = portal_student.user
      self.name     = user.name
      self.login    = user.login
      self.id       = portal_student.id
      self.perms    = portal_student.permission_forms
    end
  end

  class ClazzView < Struct.new(:id, :name, :students, :word)
    def initialize(portal_clazz)
      self.name     = portal_clazz.name
      self.word     = portal_clazz.class_word
      self.id       = portal_clazz.id
      self.students = portal_clazz.students.joins(:user).order('users.last_name').map{ |s| StudentView.new(s)}
    end
  end

  class TeacherView < Struct.new(:name, :email, :login, :clazzes, :id)
    def initialize(teacher)
      user         = teacher.user
      self.name    = user.name
      self.login   = user.login
      self.email   = user.email
      self.id      = user.id
      self.clazzes = teacher.clazzes.map { |c| ClazzView.new(c)   }
      self.clazzes = clazzes.reject      { |c| c.students.size < 1}
    end
  end

  public

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

  def update_forms
    authorize Portal::PermissionForm
    student_id     = params['student_id']
    permission_ids = params['permission_ids']
    status = 400
    respond_to do |format|
      format.js do
        if update_student_permissions(student_id, permission_ids)
          status = 200
        end
        render :nothing => true, :status => status
      end
    end
  end

  def create
    authorize Portal::PermissionForm
    form_data = params['portal_permission']
    if form_data && (!form_data['name'].blank?)
      form = Portal::PermissionForm.create(:name => form_data['name'], :url => form_data['url'], :project_id => form_data['project_id'])
    end
    redirect_to action: 'index'
  end

  def remove_form
    form = Portal::PermissionForm.find(params[:id])
    authorize form, :destroy?
    form.destroy
    redirect_to action: 'index'
  end
end
