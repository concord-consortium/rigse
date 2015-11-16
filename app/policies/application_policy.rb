class ApplicationPolicy
  attr_reader :user, :original_user, :request, :record

  def initialize(context, record)
    @user = context.user
    @original_user = context.original_user
    @request = context.request
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    new_or_create?
  end

  def new?
    new_or_create?
  end

  def update?
    update_edit_or_destroy?
  end

  def edit?
    update_edit_or_destroy?
  end

  def destroy?
    update_edit_or_destroy?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(context, scope)
      @user = context.user
      @scope = scope
    end

    def all
      # return scoped instead of all so that methods can be chained after
      scope.scoped
    end

    def none
      # hack to return an empty relation pre Rails 4
      scope.where("1 = 0")
    end

    def resolve
      all
    end
  end

  def new_or_create?
    not_anonymous?
  end

  def update_edit_or_destroy?
    changeable?
  end

  def not_anonymous?
    user && !user.anonymous?
  end

  def changeable?
    user && record.respond_to?(:changeable?) ? record.changeable?(user) : true
  end

  def project_admin?
    user && user.is_project_admin?
  end

  # from old restricted_controller

  def manager?
    has_roles?('manager','admin','district_admin')
  end

  def admin_or_manager?
    has_roles?('admin', 'manager')
  end

  def manager_or_researcher?
    user && (user.is_project_admin? || has_roles?('manager','admin','researcher'))
  end

  def admin?
    has_roles?('admin')
  end

  def admin_or_project_admin?
    user && (user.is_project_admin? || has_roles?('admin'))
  end

  def manager_or_project_admin?
    user && (user.is_project_admin? || has_roles?('admin','manager'))
  end

  def manager_or_researcher_or_project_researcher?
    user && (user.is_project_researcher? || manager_or_researcher?)
  end

  def admin_or_config?
    user && (user.has_role?('admin') || request.format == :config)
  end

  def author?
    has_roles?('author')
  end

  def student?
    user && !user.portal_student.nil?
  end

  def has_roles?(*roles)
    user && user.has_role?(*roles)
  end

end
